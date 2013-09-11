require "mvcli/action"

module MVCLI
  class App < MVCLI::Core
    requires :router

    def call(command)
      Scope.new(bootstrap) do
        action = router[command]
        action.call command
      end
    end

    def bootstrap
      Map command: command, app: self, cortex: cortex, actions: Action
    end

    def cortex
      Cortex.new do |cortex|
        Core.each do |cls|
          cortex << cls
        end
        #discover plugins here
      end
    end

    def main(argv = ARGV.dup, input = $stdin, output = $stdout, log = $stderr, env = ENV.dup)
      call Command.new(argv, input, output, log, env)
    end

    def self.main(*args)
      new.main *args
    end
  end
end
