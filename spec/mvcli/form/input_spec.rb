require "spec_helper"
require "mvcli/form/input"

describe "Form Inputs" do
  use_natural_assertions
  Given(:input) {MVCLI::Form::Input.new :field, type, options, &block}
  Given(:type) {Object}
  Given(:options) {{}}
  Given(:block) {nil}
  describe "with an integer type" do
    Given(:type) {Integer}
    context "when accessing a single value" do
      When(:value) {input.value field: 5}
      Then {value == 5}
    end
    context "when accessing an array of values" do
      When(:value) {input.value field: [1,2,3]}
      Then {value == 1}
    end
    context "when accessing a nil value" do
      When(:value) {input.value field: nil}
      Then {value.nil?}
    end
  end
  describe "with a list of integers" do
    Given(:type) {[Integer]}
    context "when accessing an value represented as a single" do
      When(:value) {input.value field: 5}
      Then {value == [5]}
    end
    context "when accessing a value represented as an array" do
      When(:value) {input.value field: [1,2,3]}
      Then {value == [1,2,3]}
    end
    context "when accessing a nil value" do
      When(:value) {input.value field: nil}
      Then {value == []}
    end
    describe "with decoding" do
      Given(:block) {->(s) { Integer s * 2 } }
      context "with singular value" do
        When(:value) {input.value field: '1'}
        Then {value == [11]}
      end
      context "with array value" do
        When(:value) {input.value field: ['1', '2']}
        Then {value == [11,22]}
      end
      context "with a sparse array value" do
        When(:value) {input.value field: ['1', nil, '2']}
        Then {value == [11,22]}
      end
      context "with an empty list" do
        When(:value) {input.value field: []}
        Then {value == []}
      end
      context "with a nil value" do
        When(:value) {input.value field: nil}
        Then {value == []}
      end
    end
  end
  describe "with decoding" do
    Given(:block) { ->(s) { Integer s * 2}}

    context "when accessed" do
      When(:value) {input.value field: ['1']}
      Then {value == 11}
    end
    context "when accessing a nil value and no default" do
      When(:value) {input.value field: nil}
      Then {value.nil?}
    end
  end

  describe "with a default" do
    Given(:options) {{default: 5}}
    context "when accesing nil" do
      When(:value) {input.value field: nil}
      Then {value == 5}
    end
    context "when accessing a value" do
      When(:value) {input.value field: 10}
      Then {value == 10}
    end
  end
end
