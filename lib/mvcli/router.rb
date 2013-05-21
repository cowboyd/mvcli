require "map"

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
      @routes << Route.new(pattern, @actions[action], options)
    end

    def call(command)
      if route = @routes.find {|r| r.matches? command}
        return route.call command
      end
      fail RoutingError, "no route matches '#{command.argv.join ' '}'"
    end

    class Route
      def initialize(pattern, action, options = {})
        @pattern, @action, @options = pattern.to_s, action, options
      end

      def matches?(command)
        segments = @pattern.split /\s+/
        segments.each_with_index do |s, i|
          return false unless command.argv[i] && s.to_s == command.argv[i]
        end
        return true
      end

      def call(command)
        @action.call command
      end
    end
  end
end
