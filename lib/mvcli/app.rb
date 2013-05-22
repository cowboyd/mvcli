require_relative "middleware"
require_relative "command"
require_relative "actions"
require_relative "router"

module MVCLI
  class App
    def initialize
      @router = Router.new Actions.new root
      @router.instance_eval route_file.read, route_file.to_s, 1
    end

    def call(command)
      @router.call command
    end

    def root
      self.class.root or fail "Invalid App: undefined application root directory"
    end

    def route_file
      root.join 'app/routes.rb'
    end

    class << self
      attr_accessor :root
    end

    def main(argv = ARGV.dup, input = $stdin, output = $stdout, log = $stderr, env = ENV.dup)
      call Command.new(argv, input, output, log, env)
    end

    def self.main(*args)
      new.main *args
    end
  end
end
