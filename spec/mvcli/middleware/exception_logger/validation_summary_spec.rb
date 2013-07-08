require "spec_helper"
require "mvcli/validatable"
require "mvcli/middleware/exception_logger/validation_summary"

describe "ValidationSummary" do
  use_natural_assertions
  Given(:validator) { MVCLI::Validatable::Validator.new }
  Given(:object) { Object.new }
  Given(:validation) { validator.validate object }
  Given(:summary) { MVCLI::Middleware::ExceptionLogger::ValidationSummary.new validation }
  context "With a simple validation" do
    Given do
      validator.validates(:foo, "You dun goofed", nil: true) {|foo| foo != nil}
      validator.validate object
    end

    context "When validation fails" do
      When { object.stub(:foo) }
      Then { summary.keys.first == "foo" }
      And { summary.values.first == ["You dun goofed"] }
    end
  end
end
