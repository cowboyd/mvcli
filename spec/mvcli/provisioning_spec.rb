require "spec_helper"
require "mvcli/provisioning"

describe "Provisioning" do
  use_natural_assertions

  describe "Scope" do
    Given(:scope) { MVCLI::Provisioning::Scope.new options }
    Given(:command) { double :Command }
    Given(:cortex) { double :Cortex }
    Given(:mod) { Module.new {include MVCLI::Provisioning} }
    Given(:cls) { m = mod; Class.new {include m} }
    Given(:obj) { cls.new }

    context "when the command is required" do
      Given { mod.requires :command }
      Given(:options) { {command: command} }
      When(:result) { scope.evaluate { obj.command } }
      Then { result == command }
    end
    context "when the cortex is required" do
      Given { mod.requires :cortex }
      Given(:options) { {cortex: cortex} }
      Then { scope.evaluate { obj.cortex } == cortex }
    end
    context "with a requirement is specified on the module" do
      Given(:options) { {cortex: cortex} }
      Given { mod.requires :foo }
      context "when reading it but it is not present" do
        Given { cortex.stub(:read) { fail "no such provider" } }
        When(:result) { scope.evaluate { obj.foo } }
        Then { result.should have_failed StandardError, /no such/ }
        And { cortex.should have_received(:read).with(:provider, :foo)}
        context "but it is manually specified in an enclosing block" do
          When(:result) { scope.evaluate(foo: 'bar') { obj.foo} }
          Then { result == 'bar' }
          context "and then not" do
            When(:result) { scope.evaluate { obj.foo } }
            Then { result.should have_failed }
          end
        end
      end
      context "and there is a scope which satisfies the requirement" do
        Given(:foo) { Object.new }
        Given { cortex.stub(:read) { double(:Provider, value: foo)}}

        context "when a dependency is read in the context of the scope" do
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
