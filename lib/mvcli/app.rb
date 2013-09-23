require "mvcli/cortex"
require "mvcli/loader"
require "mvcli/action"
require "mvcli/command"

module MVCLI
  class App < MVCLI::Core
    requires :router

    def call(command)
      Scope.new(bootstrap command) do
        action = router[command]
        return action.call command
      end
    end

    def bootstrap(command)
      Map command: command, argv: argv, app: self, cortex: cortex, loader: loader, actions: Action
    end

    def argv
    end

    def cortex
      Cortex.new do |cortex|
        Core.each do |cls|
          cortex << cls.new if cls.path
        end
        #discover plugins here
      end
    end

    def loader
      #TODO: use generic extension mechanism
      require "mvcli/std/extensions/erb_extension"
      MVCLI::Loader.new :template => MVCLI::ERBExtension.new
    end

    def main(argv = ARGV.dup, input = $stdin, output = $stdout, log = $stderr, env = ENV.dup)
      call Command.new(argv, input, output, log, env)
    end

    def self.main(*args)
      new.main *args
    end
  end
end
