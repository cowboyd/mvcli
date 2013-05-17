require "map"

module MVCLI
  class Router
    RoutingError = Class.new StandardError
    InvalidRoute = Class.new RoutingError

    def initialize(actions = nil)
      @actions = actions || Map.new
      @root = Map.new
    end

    def root(options = {})
      action = options[:to] or fail InvalidRoute, "root routes must specify an action with ':to =>' E.g. root :to => 'foo#bar'"
      verbs = [options[:via] || :help].flatten
      verbs.each do |verb|
        @root[verb] = action
      end
    end

    def call(command)
      verb = command.argv.first || 'help'
      path = command.argv.slice(1..-1) || []
      if path.empty?
        if action_name = @root[verb]
          if action = @actions[action_name]
            return action.call command
          end
        end
      end
      fail RoutingError, "#{path.join(':')} does not respond to #{verb}"
    end
  end
end
