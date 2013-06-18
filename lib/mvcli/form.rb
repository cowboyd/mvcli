require "mvcli/provisioning"

module MVCLI
  class Form
    requires :decoders

    def initialize(params = {})
      @source = params
    end

    class << self
      def input(name, type, options = {}, &block)
        define_method(name) do
          decoders[type].call @source[name], &block
        end
      end
    end
  end
end
