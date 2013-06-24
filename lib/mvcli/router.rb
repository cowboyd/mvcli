require "map"
require "mvcli/router/pattern"
require "mvcli/argv"

module MVCLI
  class Router
    RoutingError = Class.new StandardError
    InvalidRoute = Class.new RoutingError

    def initialize(actions = nil)
      @actions = actions || Map.new
      @routes = []
    end

    def match(options)
      pattern, action = options.first
      options.delete pattern
      @routes << Route.new(pattern, @actions, action, options)
    end

    def call(command)
      @routes.each do |route|
        if match = route.match(command)
          return match.call command
        end
      end
      fail RoutingError, "no route matches '#{command.argv.join ' '}'"
    end

    class Route
      def initialize(pattern, actions, action, options = {})
        @pattern = Pattern.new pattern.to_s
        @actions, @action, @options = actions, action, options
      end

      def match(command)
        argv = MVCLI::Argv.new command.argv
        match = @pattern.match(argv.arguments)
        if match.matches?
          proc do |command|
            action = @actions[@action] or fail "no action found for #{@action}"
            action.call command, match.bindings
          end
        end
      end
    end
  end
end
