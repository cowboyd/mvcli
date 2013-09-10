require "spec_helper"
require "mvcli/action"

describe "MVCLI::Action" do
  use_natural_assertions

  Given(:command) { double :Command }
  Given(:cortex) { double :Cortex }
  Given(:action) { MVCLI::Action.new match, mapping }
  Given(:match) { double :Match, :bindings => double(:Bindings) }
  Given { action.stub(:cortex) { cortex } }
  Given { action.stub(:middleware) { ->(cmd, &block) { block.call Map cmd: cmd } } }

  context "when the mapping is callable" do
    Given(:mapping) { ->(command) { command } }
    When(:result) { action.call command }
    Then { result.cmd == command }
  end

  context "when the mapping is a string" do
    Given(:mapping) { 'servers#show' }
    Given(:controller) { double(:Controller, call: Object.new) }
    Given(:controller_class) { double :ControllerClass, new: controller }
    Given { cortex.stub(:read) { controller_class } }

    When(:result) { action.call command }
    Then { result == controller.call }
    Then { cortex.should have_received(:read).with(:controller, 'servers') }
    Then { controller_class.should have_received(:new).with 'show', match.bindings }
  end
end
