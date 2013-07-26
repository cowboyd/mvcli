require "mvcli/decoding"
require "mvcli/validatable"

module MVCLI
  class Form
    include MVCLI::Validatable

    def initialize(params = {}, type = Map)
      @source = params
      @target = type
    end

    def value
      self.class.output.call self
    end

    def attributes
      self.class.inputs.reduce(Map.new) do |map, pair|
        name, input = *pair
        map.tap do
          map[name] = input.value(@source, self) do |value|
            value.is_a?(Form) ? value.attributes : value
          end
        end
      end
    end

    class Decoder
      def initialize(form, names)
        @form, @names = form, names
      end

      def call(string)
        @form.new Map Hash[@names.zip string.split ':']
      end

      def to_proc
        method(:call).to_proc
      end
    end

    class << self
      attr_accessor :target
      attr_reader :inputs, :output

      def inherited(base)
        base.class_eval do
          @inputs = Map.new
        end
      end

      def decoder
        Decoder.new self, inputs.keys
      end

      def output(&block)
        if block_given?
          @output = block
        else
          @output = ->(form) { form.attributes }
        end
      end

      def input(name, target, options = {}, &block)
        if block_given?
          form = Class.new(MVCLI::Form, &block)
          form.target = [target].flatten.first
          validates_child name
          input = Input.new(name, target, options, &form.decoder)
        else
          input = Input.new(name, target, options, &options[:decode])
        end
        @inputs[name] = input
        if options[:required]
          if target.is_a?(Array)
            validates(name, "cannot be empty", nil: true, each: false) {|value| value && !value.empty?}
          else
            validates(name, "is required", nil: true) {|value| !value.nil?}
          end
        end
        define_method(name) do
          input.value @source, self
        end
      end
    end
  end
end

require "mvcli/form/input"
