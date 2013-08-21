require "spec_helper"

describe "MVCLI Cores" do
  use_natural_assertions
  Core = MVCLI::Core
  Given(:namespace) { Module.new }
  Given(:core) { Core.new path: finder, namespace: namespace }
  Given(:finder) { double :Finder }
  Given do
    finder.stub(:exists?) { true }
    finder.stub(:read) { artifact }
  end

  describe "the query interface" do
    Given { finder.stub(:exists?)}
    When { core.exists? :provider, 'naming' }
    Then { finder.should have_received(:exists?).with(:provider, 'naming') }
  end

  describe "reading the extension into memory" do
    context "when it does not exist" do
      Given { finder.stub(:exists?) { false } }
      When(:result) { core.read :provider, 'naming' }
      Then { result.should have_failed MVCLI::ExtensionNotFound  }
    end
    context "when it does exist" do
      Given(:artifact) { Class.new }
      When(:result) { core.read :provider, 'naming' }
      Then { finder.should have_received(:read).with(namespace, :provider, 'naming') }
      And { result == artifact }
      And { result.core == core }
      And { result.new.core == core }
    end
  end
end
