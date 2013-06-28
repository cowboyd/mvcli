require "spec_helper"
require "mvcli/validatable"

describe "a validator" do
  use_natural_assertions
  Given(:object) {Object.new}
  Given(:validator) {MVCLI::Validatable::Validator.new}
  Given(:validation) { validator.validate object }
  context "when it validates a field that does not exist on the object" do
    Given {validator.validates(:does_not_exist, "invalid") {}}
    When(:validation) {validator.validate object}
    Then {not validation.errors[:does_not_exist].empty?}
    Then {not validation.valid?}
  end
  describe "validating a child" do
    Given {validator.validates_child(:some_child)}
    context "when it is nil" do
      When(:validation) {validator.validate(mock(:Object, :some_child => nil))}
      Then {validation.valid?}
    end
    context "when it does not exist" do
      When(:validation) {validator.validate(Object.new)}
      Then {not validation.errors[:some_child].nil?}
      And {not validation.valid?}
    end
  end

  describe "validating a nil field" do
    Given { object.stub(:property) {nil} }
    context "when the validate-on-nil option is passed" do
      When { validator.validates(:property, "check nil", nil: true) {false} }
      Then { not validation.valid? }
      And { not validation.violations[:property].empty? }
    end
    context "when the validate on nil option is not passed" do
      When { validator.validates(:property, "check nil") {false}}
      Then { validation.valid? }
    end
  end
end
