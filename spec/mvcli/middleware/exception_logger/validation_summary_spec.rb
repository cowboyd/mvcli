require "spec_helper"
require "mvcli/validatable"
require "mvcli/middleware/exception_logger/validation_summary"

describe "ValidationSummary" do
  use_natural_assertions
  Given(:validator) { MVCLI::Validatable::Validator.new }
  Given(:object) { Object.new }
  Given(:validation) { validator.validate object }
  Given(:summary) { MVCLI::Middleware::ExceptionLogger::ValidationSummary.new validation }
  Given(:rollup) { summary.each }

  context "with a simple validation" do
    Given do
      validator.validates(:foo, "You dun goofed", nil: true) {|foo| foo != nil}
      validator.validate object
    end

    context "when validation fails" do
      When { object.stub(:foo) }
      Then { rollup.first == ["foo", ["You dun goofed"]] }
    end
    context "when there is an access error" do
      When { object.stub(:foo) {fail "bad access"}}
      Then { rollup.first == ["foo", ["RuntimeError: bad access"]] }
    end
    context "when the validation fails on an array property" do
      When {object.stub(:foo) {[nil]}}
      Then {rollup.first == ["foo[0]", ["You dun goofed"]]}
    end
  end
  context "with a nested validation" do
    Given(:child) { double(:Child) }
    Given(:child_validator) { MVCLI::Validatable::Validator.new }
    Given do
      object.stub(:bars) {[child, child]}
      validator.validates_child :bars
      child_validator.validates(:bazzes, "bad baz") {|baz| not baz.nil? }
      child.stub(:validation) {child_validator.validate child}
    end
    context "with an invalid nested associtaion" do
      When { child.stub(:bazzes) {['valid', nil, 'valid']} }
      Then { rollup.first == ["bars[0].bazzes[1]", ["bad baz"]] }
    end
  end
end
