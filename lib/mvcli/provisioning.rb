require "map"
require "active_support/concern"

module MVCLI
  module Provisioning
    extend ActiveSupport::Concern
    UnsatisfiedRequirement = Class.new StandardError
    MissingScope = Class.new StandardError

    class Scope
      def initialize(provisioner)
        @provisioner = provisioner
        @values = Map.new
      end

      def [](name)
        @values[name] ||= @provisioner[name]
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


    module ClassMethods
      def requires(*deps)
        deps.each do |dep|
          self.define_method(dep) {Scope[dep]}
        end
      end
    end
  end
end
