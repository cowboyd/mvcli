require "mvcli/provisioning"

module MVCLI
  class Form
    requires :decoders

    def initialize(params = {})
      @source = params
    end

    class << self
      def input(name, type, options = {}, &block)
        default_value = options[:default]
        default = default_value.respond_to?(:call) ? default_value : proc {default_value}
        define_method(name) do
          value = @source[name] || instance_exec(&default)
          decoders[type].call(value, &block)
        end
      end
    end
  end
end
