require "map"
require "mvcli/router/pattern"
require "mvcli/argv"

module MVCLI
  class Router
    RoutingError = Class.new StandardError
    InvalidRoute = Class.new RoutingError

    attr_reader :routes

    def initialize(app, actions = nil)
      @app = app
      @actions = actions || Map.new
      @routes = []
      @macros = []
    end

    def macro(options)
      @macros.push Macro.new options
    end

    def match(options)
      pattern, action = options.first
      options.delete pattern
      @routes << Route.new(@app, pattern, @actions, action, options)
    end

    def call(command)
      argv = @macros.reduce(command.argv) do |args, macro|
        macro.expand args
      end
      @routes.each do |route|
        if match = route.match(argv)
          return match.call command
        end
      end
      fail RoutingError, "no route matches '#{command.argv.join ' '}'"
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
      attr_reader :actions, :action, :pattern
      def initialize(app, pattern, actions, action, options = {})
        @app = app
        @pattern = Pattern.new pattern.to_s
        @actions, @action, @options = actions, action, options
      end

      def match(argv)
        argv = MVCLI::Argv.new argv
        match = @pattern.match(argv.arguments)
        if match.matches?
          proc do |command|
            action = @actions[@action] or fail "no action found for #{@action}"
            action.call command, match.bindings, @app
          end
        end
      end
    end
  end
end
