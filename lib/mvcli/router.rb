require "map"
require "mvcli/router/pattern"
require "mvcli/argv"

module MVCLI
  class Router
    class RoutingError < StandardError; end
    requires :actions

    attr_reader :routes
    attr_reader :macros

    def initialize
      @routes = []
      @macros = []
    end

    def call(command)
      argv = @macros.reduce(command.argv) do |args, macro|
        macro.expand args
      end
      @routes.each do |route|
        if action = route.match(argv)
          return action
        end
      end
      fail RoutingError, "no route matches '#{command.argv.join ' '}'"
    end

    alias_method :[], :call

    class DSL < BasicObject
      attr_reader :router

      def initialize
        @router = Router.new
      end

      def macro(options)
        @router.macros.push Macro.new options
      end

      def match(options)
        pattern, action = options.first
        options.delete pattern
        @router.routes << Route.new(router, pattern, action, options)
      end
    end

    class Macro
      def initialize(options)
        @pattern, @expansion = options.first
      end

      def expand(argv)
        argv.join(" ").gsub(@pattern, @expansion).split /\s+/
      end
    end

    class Route
      def initialize(router, pattern, action, options = {})
        @pattern = Pattern.new pattern.to_s
        @router, @action, @options = router, action, options
      end

      def match(argv)
        argv = MVCLI::Argv.new argv
        match = @pattern.match(argv.arguments)
        if match.matches?
          @router.actions.new match, @action
        end
      end
    end
  end
end
