require "map"

module MVCLI
  module Provisioning
    MissingScope = Class.new StandardError

    def self.included(base)
      base.send :extend, Requires
    end

    module Requires
      def requires(*deps)
        deps.each do |dep|
          self.send(:define_method, dep) {Scope[dep]}
        end
      end
    end


    ::Object.send :include, self

    class Scope
      requires :cortex
      attr_reader :command

      def initialize(options = {}, &block)
        @providers = Map options
        evaluate &block if block_given?
      end

      def [](name)
        unless provider = @providers[name]
          provider = @providers[name] = cortex.read :provider, name
        end
        if provider.respond_to?(:value)
          provider.value
        elsif provider.respond_to?(:new)
          provider.new.value
        else
          provider
        end
      end

      def evaluate
        old = self.class.current
        self.class.current = self
        yield
      ensure
        self.class.current = old
      end

      private

      def const(value)
        Constant.new value
      end

      class << self
        def current
          Thread.current[self.class.name]
        end

        def current!
          current or fail MissingScope, "attempting to access scope, but none is active!"
        end

        def current=(scope)
          Thread.current[self.class.name] = scope
        end

        def [](name)
          current![name]
        end
      end

      class Constant
        attr_reader :value

        def initialize(value)
          @value = value
        end
      end
    end
  end
end
