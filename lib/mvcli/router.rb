require "map"
require_relative "router/pattern"

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
      if route = @routes.find {|r| r.matches? command}
        return route.call command
      end
      fail RoutingError, "no route matches '#{command.argv.join ' '}'"
    end

    class Route
      def initialize(pattern, actions, action, options = {})
        @pattern = Pattern.new pattern.to_s
        @actions, @action, @options = actions, action, options
      end

      def matches?(command)
        @pattern.match(command.argv).matches?
      end

      def call(command)
        action = @actions[@action] or fail "no action found for #{@action}"
        action.call command
      end
    end
  end
end
