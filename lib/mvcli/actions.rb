require "map"
require "mvcli/controller"
require "mvcli/form"
require_relative "loader"
require_relative "renderer"

module MVCLI
  class Actions
    def initialize(root, loader = Loader.new, renderer = nil)
      @loader = loader
      @renderer = renderer || Renderer.new(root)
    end

    def [](key)
      return key if key.respond_to?(:call)
      controller, method = key.split('#')
      Action.new @loader, @renderer, controller, method
    end

    class Action
      def initialize(loader, renderer, controller, method)
        @loader = loader
        @renderer = renderer
        @controller = controller
        @method = method
      end

      def call(command, bindings = Map.new, app = nil)
        controller = @loader.load :controller, @controller, bindings, app
        context = controller.send @method
        path = [@controller, @method].join('/')
        @renderer.render command.output, path, context
        return 0
      end
    end
  end
end
