require "spec_helper"
require "mvcli/middleware/exit_status"

describe MVCLI::Middleware::ExitStatus do
  use_natural_assertions
  Given(:command) { double(:Command) }
  Given(:middleware) { MVCLI::Middleware::ExitStatus.new }
  context "when called with code that succeeds" do
    When(:status) { middleware.call(command) {0} }
    Then { status == 0 }
  end
  context "when called with an app that fails with an exit status of 99" do
    When(:status) { middleware.call(command) {99} }
    Then { status == 99 }
  end

  context "when the upstream app yields a non-integer" do
    When(:status) { middleware.call(command) {"whoopeee!"} }
    Then { status == 0 }
  end

  context "when the upstream app raises an exception" do
    When(:status) { middleware.call(command) {fail "boom!"} }
    Then { status == 70 }
  end
end
