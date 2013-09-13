require "mvcli/middleware"
require "mvcli/middleware/exit_status"
require "mvcli/middleware/exception_logger"

class MVCLI::MiddlewareProvider
  def value
    MVCLI::Middleware.new do |middleware|
      middleware << MVCLI::Middleware::ExitStatus.new
      middleware << MVCLI::Middleware::ExceptionLogger.new
    end
  end
end
