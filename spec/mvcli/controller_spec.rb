require "spec_helper"
require "mvcli/controller"

describe "A Controller" do
  use_natural_assertions

  Given(:controller) { MVCLI::Controller.new name, method, params }
  Given(:app) { double :App }
  Given(:path) { double :Path }
  Given(:command) { double(:Command, output: StringIO.new ) }
  Given { controller.stub(:app) { app } }
  Given { app.stub(:path) { path } }
  Given { path.stub(:read)  { "Hello <%= this.name %>" } }
  Given { path.stub(:to_s) { "/path/to/template.txt.erb" } }

  context "when called with the 'show' action" do
    Given(:name) { 'servers' }
    Given(:method) { 'show' }
    Given(:params) { Map name: 'World' }
    Given { controller.stub(:show) { params } }
    When(:exit_status) { controller.call command }
    Then { exit_status == 0 }
    Then { command.output.string == 'Hello World' }
    And { path.should have_received(:read).with "views/servers/show.txt.erb"}
  end
end
