require_relative "loader"
require_relative "renderer"

module MVCLI
  class Actions
    def initialize(root, loader = nil, renderer = nil)
      @loader = loader || Loader.new(root)
      @renderer = renderer || Renderer.new(root)
    end

    def [](key)
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

      def call(command)
        controller = @loader.load :controller, @controller
        context = controller.send @method
        path = [@controller, @method].join('/')
        @renderer.render command.output, path, context
        return 0
      end
    end
  end
end
