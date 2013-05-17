module MVCLI
  class Actions
    def initialize(loader, renderer)
      @loader = loader
      @renderer = renderer
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
        fail LoadError, "no such controller: #{@controller}" unless controller
        context = controller.send @method
        path = [@controller, @method].join('/')
        @renderer.render command.output, path, context
      end
    end
  end
end
