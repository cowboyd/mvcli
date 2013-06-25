require "spec_helper"
require "mvcli/validatable"

describe "a validator" do
  Given(:validator) {MVCLI::Validatable::Validator.new}
  context "when it validates a field that does not exist on the object" do
    Given {validator.validates(:does_not_exist, "invalid") {}}
    When(:validation) {validator.validate(Object.new)}
    Then {validation.errors[:does_not_exist].class < NameError}
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
end
