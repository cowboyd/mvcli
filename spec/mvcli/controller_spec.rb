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

    context "when there's a corresponding form" do
      Given { controller.stub(:argv) { double(:argv, options: {}) } }
      Given { cortex.stub(:exists?).with(:form, "servers/show") { true } }
      Given { cortex.stub(:read).with(:form, "servers/show") { double(:Form, new: form) } }
      Given{ form.stub(:validate!) { true } }
      Given(:form) { double :form }
      Then{ controller.form == form }
    end

    context "when there's not a corresponding form" do
    end
  end
end
