require "spec_helper"
require "mvcli/erb"

describe "MVCLI::ERB" do
  Given(:erb) {MVCLI::ERB.new}
  context "when I compile a template" do
    Given(:output) {""}
    Given(:template) {erb.compile "name: <%= name %>"}
    context "and call it with a context" do
      When {template.call mock(:Context, :name => 'Charles'), output}
      Then {output.should eql "name: Charles"}
    end
  end
end
