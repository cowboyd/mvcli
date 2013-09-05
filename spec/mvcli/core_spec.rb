require "spec_helper"

describe "MVCLI Cores" do
  use_natural_assertions

  Given(:loader) { double(:Loader) }
  Given { core.stub(:loader) { loader } }
  Given { loader.stub(:exists?) { true } }


  describe "with explicit values for path and namespace" do
    Given(:core) { MVCLI::Core.new path: path, namespace: namespace}
    Given(:path) { double(:Path) }
    Given(:namespace) { Module.new }


    describe "the query interface" do
      Then { core.exists? :provider, 'naming' }
      And { loader.should have_received(:exists?).with(path, :provider, 'naming') }
    end

    describe "reading the extension into memory" do
      context "when it does not exist" do
        Given { loader.stub(:exists?) { false } }
        When(:result) { core.read :provider, 'naming' }
        Then { result.should have_failed MVCLI::ExtensionNotFound  }
      end
      context "when it does exist" do
        Given(:artifact) { Class.new }
        Given { loader.stub(:read) { artifact } }
        When(:result) { core.read :provider, 'naming' }
        Then { loader.should have_received(:read).with(path, :provider, 'naming', namespace) }
        And { result == artifact }
        And { result.core == core }
        And { result.new.core == core }
      end
    end
  end

  describe "with no explicit values for path and namespace" do
    Given(:core) { MVCLI::Core.new  }
    When(:result) { core.path }
    Then { result.should have_failed MVCLI::InvalidPath }
    Then { core.namespace == Object }
  end

  describe "resolving the namespace" do
    When(:namespace) { core.namespace }

    describe "when the class is anonymous" do
      Given(:core) { Class.new(MVCLI::Core).new }
      Then { namespace == Object }
      describe "but the namespace attribute is set" do
        Given { core.class.namespace = MVCLI }
        Then { namespace == MVCLI }
      end
    end
    describe "when the class is named" do
      Given(:core) do
        module MVCLI
          module Test
            class MyCore < MVCLI::Core
              new
            end
          end
        end
      end
      Then { namespace == MVCLI::Test }
      describe "but the namespace class attribute is set" do
        Given { core.class.namespace = MVCLI }
        Then { namespace == MVCLI }
      end
    end
  end
end
