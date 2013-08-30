require "spec_helper"
require "mvcli/provisioning"

describe "Provisioning" do
  use_natural_assertions

  describe "Scope" do
    Given(:cortex) { double :Cortex }
    Given(:mod) { Module.new {include MVCLI::Provisioning} }
    Given(:cls) { m = mod; Class.new {include m} }
    Given(:obj) { cls.new }
    Given(:command) { double(:Command) }
    Given(:scope) { MVCLI::Provisioning::Scope.new command, cortex }

    context "when the command is required" do
      Given { mod.requires :command }
      When(:result) { scope.evaluate { obj.command } }
      Then { result == command }
    end
    context "when the cortext is required" do
      Given { mod.requires :cortex }
      Then { scope.evaluate { obj.cortex } == cortex }
    end
    context "with a requirement is specified on the module" do
      Given { mod.requires :foo }
      context "when accessing it but it is not present" do
        Given { cortex.stub(:access) { fail "no such provider" } }
        When(:result) { scope.evaluate { obj.foo } }
        Then { result.should have_failed }
        And { cortex.should have_received(:access).with(:provider, :foo)}
      end
      context "and there is a scope which satisfies the requirement" do
        Given(:foo) { Object.new }
        Given { cortex.stub(:access) { double(:Provider, value: foo)}}

        context "when a dependency is accessed in the context of the scope" do
          When(:result) { scope.evaluate { obj.foo } }
          Then { result == foo }
        end
      end
      context "accessing requirements with no scope" do
        When(:result) { obj.foo }
        Then { result.should have_failed MVCLI::Provisioning::MissingScope }
      end
    end
  end
end
