require "spec_helper"
require "mvcli/std/extensions/erb_extension"

describe "The ERB Extension" do
  Given(:extension) { MVCLI::ERBExtension.new }
  Given(:name) { 'foo/bar' }

  describe "to_path" do
    When(:path) { extension.to_path name, extension_type }
    context "when the extension_type is a string" do
      Given(:extension_type) { "template" }
      Then { path == "templates/foo/bar.txt.erb" }
    end
    context "when the extension_type is a symbol" do
      Given(:extension_type) { :template }
      Then { path == "templates/foo/bar.txt.erb" }
    end
    context "when the extension_type is not 'template'" do
      Given(:extension_type) { :not_a_template }
      Then { path.should have_failed ArgumentError }
    end
  end
  describe "define" do
    Given(:extension_type) { :template }
    Given(:namespace) { Object }
    When(:template) { extension.define(name, bytes, extension_type, namespace) }
    context "with a valid ERB template" do
      Given(:bytes) { "Hello <%= this.name %>" }
      Given(:output) { StringIO.new }
      When { template.call Map(name: 'Bob'), output }
      Then { output.string == 'Hello Bob' }
    end
  end
end
