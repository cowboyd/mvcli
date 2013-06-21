require "mvcli/provisioning"
require "mvcli/validatable"

module MVCLI
  class Form
    include MVCLI::Validatable

    def initialize(params = {}, type = Map)
      @errors = Map.new
      @source = params
      @target = type
    end

    def output
      @target.new attributes
    end

    def attributes
      self.class.inputs.reduce(Map.new) do |map, name|
        map.tap do
          map[name] = self.send(name).output
        end
      end
    end

    class << self
      attr_reader :inputs, :decoding
      def inherited(base)
        base.class_eval do
          @inputs = []
          @decoding = MVCLI::Decoding.new
        end
      end

      def decode
        yield @decoding
      end

      def input(name, type, options = {}, &block)
        @inputs << name
        if options[:required]
          if type.is_a?(Array)
            validates(name, "cannot be empty", nil: true) {|value| value && value.length > 1}
          else
            validates(name, "is required", nil: true) {|value| !value.nil?}
          end
        end

        if block_given?
          subform = Class.new(MVCLI::Form, &block)
          validates_child name
          @decoding.send(name) do |value|
            if value.is_a?(Array)
              [value].flatten.map do |element|
                subform.new(element, type.first)
              end
            else
              subform.new(value, type.first)
            end
          end
        end

        define_method(name) do
          if raw = @source.is_a?(String) ? @source : @source[name]
            self.class.decoding.call name, raw, type
          else
            default = options[:default]
            default.respond_to?(:call) ? instance_exec(&default) : default
          end
        end
      end
    end
  end
end
