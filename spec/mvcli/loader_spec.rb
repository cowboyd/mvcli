require "spec_helper"
require "mvcli/loader"

describe "MVCLI::Loader" do
  use_natural_assertions

  Given(:path) { double :Path }
  Given(:loader) {MVCLI::Loader.new}
  Given { path.stub(:read) { content }}

  describe "querying if an extension exists" do
    context "when it does not exists in the path" do
      Given { path.stub(:exists?) { false } }
      Then { not loader.exists? path, :provider, 'bar' }
      And { path.should have_received(:exists?).with 'providers/bar_provider.rb' }
    end
    context "when it does exist in the path" do
      Given { path.stub(:exists?) { true } }
      Then { loader.exists? path, :provider, 'bar' }

      context "when the extension is read and it matches the naming conventions" do
        Given { module ::ANamespace; end }
        Given(:content) { "class ANamespace::BarProvider; def barf; end; end" }
        When(:provider_class) { loader.read path, ANamespace, :provider, 'bar' }
        Then { path.should have_received(:read).with('providers/bar_provider.rb') }
        Then { not provider_class.nil? }
        Then { defined? ::ANamespace::BarProvider }
        And { provider_class == ::ANamespace::BarProvider }
        And { provider_class.method_defined? :barf }
        after do
          Object.send :remove_const, :ANamespace
        end
      end
      context "when extension does not match naming conventions" do
        Given(:content) { "class ArgleBargle; end" }
        When(:result) { loader.read path, Object, :provider, 'bar' }
        Then { result.should have_failed LoadError }
      end
      context "when extension matches naming conventions but is not in the right namespace" do
        Given { module ::OtherNamespace; end }
        Given(:content) { "class Object::BarProvider; end" }
        When(:result) { loader.read path, OtherNamespace, :provider, 'bar' }
        Then { result.should have_failed LoadError }
        after do
          Object.send :remove_const, :OtherNamespace
        end
      end
    end
  end
end
