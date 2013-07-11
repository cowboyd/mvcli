require "mvcli/erb"
require "mvcli/validatable"
require "mvcli/middleware/exception_logger/validation_summary"

module MVCLI
  class Middleware
    class ExceptionLogger
      def call(command)
        yield command
      rescue MVCLI::Validatable::ValidationError => e
        ValidationSummary.new(e.validation).write command.log
        raise e
      rescue Exception => e
        command.log << "#{e.class}: #{e.message}\n"
        command.log << "\n#{e.backtrace.join("\n")}\n" if ENV['backtrace']
        raise e
      end
    end
  end
end
