module MVCLI
  class Middleware
    class ExceptionLogger
      def call(command)
        yield command
      rescue Exception => e
        command.log << e.message + "\n"
        raise e
      end
    end
  end
end
