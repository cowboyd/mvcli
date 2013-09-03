require "spec_helper"
require "mvcli/cortex"

describe "A Cortex" do
  use_natural_assertions
  Given(:cortex) { MVCLI::Cortex.new }

  describe "without any cores" do
    When(:result) { cortex.read :extension, 'foo/bar/baz' }
    Then { result.should have_failed MVCLI::ExtensionNotFound }
  end

  describe "with a few cores" do
    Given(:core1) { cortex << double(:Core1) }
    Given(:core2) { cortex << double(:Core2) }

    context "when we access an object" do
      When(:extension) { cortex.read :controller, "admin/users" }

      context "and it is defined and exists" do
        Given { core1.stub(:read) { double(:Extension, core: 1) } }
        Given { core2.stub(:read) { double(:Extension, core: 2) } }

        Invariant { cortex.exists? :controller, "admin/users"}

        context "only in the first core" do
          Given { core1.stub(:exists?) { true } }
          Then { extension.core ==  1}
        end
        context "only in the second core" do
          Given { core1.stub(:exists?) { false } }
          Given { core2.stub(:exists?) { true } }
          Then { extension.core == 2 }
        end
        context "in both cores" do
          Given { core1.stub(:exists?) { true} }
          Given { core2.stub(:exists?) { true } }
          Then { core1.should have_received(:read) }
          Then { core2.should_not have_received(:read) }
        end
      end
    end
  end
end
