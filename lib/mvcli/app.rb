require_relative "middleware"
require_relative "command"
require_relative "router"

module MVCLI
  class App

    def initialize
      @middleware = Middleware.new
      @middleware << Router.new
    end

    def call(command)
      @middleware.call command
    end

    def root
      self.class.root or fail "Invalid App: undefined application root directory"
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
