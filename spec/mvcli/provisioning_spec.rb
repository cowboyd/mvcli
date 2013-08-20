require "spec_helper"
require "mvcli/provisioning"

describe "Provisioning" do
  use_natural_assertions
  describe "Scope" do
    Given(:provisioner) { {} }
    Given(:mod) { Module.new {include MVCLI::Provisioning} }
    Given(:cls) { m = mod; Class.new {include m} }
    Given(:obj) { cls.new }
    Given(:command) { double(:Command) }
    Given(:scope) { MVCLI::Provisioning::Scope.new command, provisioner }
    context "when the command is required" do
      Given { mod.requires :command }
      When(:result) { scope.evaluate {obj.command} }
      Then { result == command }
    end
    context "with a requirement is specified on the module" do
      Given { mod.requires :foo }
      context "when accessing it but it is not present" do
        When(:result) { scope.evaluate {obj.foo} }
        Then { result.should have_failed MVCLI::Provisioning::UnsatisfiedRequirement, /foo/ }
      end
      context "and there is a scope which satisfies the requirement" do
        Given(:foo) { Object.new }
        Given { provisioner[:foo] = foo }

        context "when a dependency is accessed in the context of the scope" do
          When(:result) { scope.evaluate {obj.foo} }
          Then { result == foo }
        end
      end
      context "accessing requirements with no scope" do
        When(:result) { obj.foo }
        Then { result.should have_failed MVCLI::Provisioning::MissingScope }
      end
    end
  end

  describe "Provisioner" do
    Given do
      ActiveSupport::Dependencies.clear
      ActiveSupport::Dependencies.autoload_paths.clear
      ActiveSupport::Dependencies.autoload_paths << File.expand_path('../dummy/app/providers', __FILE__)
    end
    Given(:provisioner) { MVCLI::Provisioning::Provisioner.new }
    context "when no provider exists for a value" do
      When(:result) { provisioner[:does_not_exist] }
      Then { result.should have_failed }
    end
    context "when a provider exists" do
      When(:result) { provisioner[:test] }
      Then { result == "here is a free value just for you!!" }
    end
  end
end
