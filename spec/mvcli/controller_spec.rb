require "spec_helper"
require "mvcli/controller"

describe "A Controller" do
  use_natural_assertions

  Given(:controller) { MVCLI::Controller.new name, method, params }
  Given(:cortex) { double(:Cortex) }
  Given(:command) { double(:Command, output: StringIO.new ) }
  Given { controller.stub(:cortex) { cortex } }
  Given { cortex.stub(:read)  { proc { |context, output| @context, @output = context, output} } }

  context "when called with the 'show' action" do
    Given(:name) { 'servers' }
    Given(:method) { 'show' }
    Given(:params) { Map name: 'World' }
    Given { controller.stub(:show) { params } }
    When(:exit_status) { controller.call command }
    Then { exit_status == 0 }
    Then { @output == command.output }
    And { cortex.should have_received(:read).with :template, "servers/show"}
  end
end
