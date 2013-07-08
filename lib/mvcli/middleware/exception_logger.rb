require "mvcli/erb"
require "mvcli/middleware/exception_logger/validation_summary"

module MVCLI
  class Middleware
    class ExceptionLogger
      def call(command)
        yield command
      rescue MVCLI::Validatable::ValidationError => e
        ValidationSummary.new(e).write command.log
      rescue Exception => e
        command.log << e.message + "\n"
        raise e
      end
    end
  end
end
