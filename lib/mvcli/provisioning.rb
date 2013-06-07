require "map"
require "active_support/concern"
require "active_support/dependencies"
require "mvcli/loader"

module MVCLI
  module Provisioning
    extend ActiveSupport::Concern
    UnsatisfiedRequirement = Class.new StandardError
    MissingScope = Class.new StandardError

    module ClassMethods
      def requires(*deps)
        deps.each do |dep|
          self.send(:define_method, dep) {Scope[dep]}
        end
      end
    end

    class Scope
      def initialize(command, provisioner)
        @command = command
        @provisioner = provisioner
      end

      def [](name)
        name.to_s == "command" ? @command : @provisioner[name]
      end

      def evaluate
        old = self.class.current
        self.class.current = self
        yield
      ensure
        self.class.current = old
      end

      def self.current
        Thread.current[self.class.name]
      end

      def self.current!
        current or fail MissingScope, "attempting to access scope, but none is active!"
      end

      def self.current=(scope)
        Thread.current[self.class.name] = scope
      end

      def self.[](name)
        current![name] or fail UnsatisfiedRequirement, "'#{name}' is required, but can't find it"
      end
    end

    class Provisioner
      def initialize
        @loader = Loader.new
        @providers = Map.new
      end
      def [](name)
        unless provider = @providers[name]
          provider = @providers[name] = @loader.load :provider, name
        end
        provider.value
      end
    end

    class Middleware
      def call(command)
        Scope.new(command, Provisioner.new).evaluate do
          yield command
        end
      end
    end
    ::Object.send :include, self
  end
end
