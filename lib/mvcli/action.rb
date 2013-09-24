require "map"

module MVCLI
  class Action
    requires :cortex, :middleware

    attr_reader :match, :mapping, :endpoint

    def initialize(match, mapping)
      @match, @mapping  = match, mapping
    end

    def call(command)
      middleware.call(command) do |command|
        endpoint.call command
      end
    end

    def endpoint
      return @endpoint if @endpoint
      if mapping.respond_to? :call
        @endpoint = mapping
      else
        require "mvcli/controller"
        controller_name, method = mapping.to_s.split('#')
        controller = cortex.read :controller, controller_name
        @enpoint = controller.new controller_name, method, match.bindings
      end
    end
  end
end
