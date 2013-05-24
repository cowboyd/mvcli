require "spec_helper"
require "mvcli/provisioning"

describe "Provisioning" do
  use_natural_assertions
  Given(:provisioner) {{}}
  Given(:mod) {Module.new {include MVCLI::Provisioning}}
  Given(:cls) {m = mod; Class.new {include m}}
  Given(:obj) {cls.new}
  Given(:container) {MVCLI::Provisioning::Scope.new provisioner}
  context "with a requirement is specified on the module" do
    Given {mod.requires :foo}
    context "when accessing it but it is not present" do
      When(:result) {container.evaluate {obj.foo}}
      Then {result.should have_failed MVCLI::Provisioning::UnsatisfiedRequirement, /foo/}
    end
    context "and there is a scope which satisfies the requirement" do
      Given(:foo) {Object.new}
      Given {provisioner[:foo] = foo}

      context "when a dependency is accessed in the context of the container" do
        When(:result) {container.evaluate {obj.foo}}
        Then {result == foo}
      end
    end
    context "accessing requirements with no scope" do
      When(:result) {obj.foo}
      Then {result.should have_failed MVCLI::Provisioning::MissingScope}
    end
  end
end
