module MVCLI
  class Command
    attr_reader :argv, :input, :output, :log, :env

    def initialize(argv, input, output, log, env)
      @argv, @input, @output, @log, @env = argv, input, output, log, env
    end
  end
end
