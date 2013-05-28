require "spec_helper"
require "mvcli/middleware/exception_logger"

describe "MVCLI::Middleware::ExceptionLogger" do
  use_natural_assertions

  Given(:command) {mock(:Command, :log => "")}
  Given(:logger) {MVCLI::Middleware::ExceptionLogger.new}
  context "with a cleanly running application" do
    When(:result) {logger.call(command) {0}}
    Then {result == 0}
  end
  context "with an app that raises an exception" do
    When(:result) {logger.call(command) {fail "boom!"}}
    Then {command.log == "boom!\n"}
    And {result.should have_failed StandardError, "boom!"}
  end
end
