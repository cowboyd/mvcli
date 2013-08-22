require "spec_helper"

describe "MVCLI Cores" do
  use_natural_assertions
  Given(:core) { MVCLI::Core.new path: path, namespace: namespace, loader: loader }
  Given(:path) { double :Path }
  Given(:namespace) { Module.new }
  Given(:loader) { double :Loader }
  Given do
    loader.stub(:exists?) { true }
  end

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
