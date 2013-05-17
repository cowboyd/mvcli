require_relative "middleware"
require_relative "command"

module MVCLI
  class App
    def initialize
      @stack = Middleware.new
    end

    def call(command)
      @stack.call command
    end

    def main(argv = ARGV.dup, input = $stdin, output = $stdout, log = $stderr, env = ENV.dup)
      call Command.new(argv, input, output, log, env)
    end

    def self.main(*args)
      new.main *args
    end
  end
end
