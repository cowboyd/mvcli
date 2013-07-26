require "map"
require "mvcli/router/pattern"
require "mvcli/argv"

module MVCLI
  class Router
    class RoutingError < StandardError; end

    def initialize(actions = nil)
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
      @routes << Route.new(pattern, @actions, action, options)
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
      def initialize(pattern, actions, action, options = {})
        @pattern = Pattern.new pattern.to_s
        @actions, @action, @options = actions, action, options
      end

      def match(argv)
        argv = MVCLI::Argv.new argv
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
