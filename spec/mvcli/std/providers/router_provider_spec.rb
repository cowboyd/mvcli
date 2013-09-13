require "spec_helper"
require "mvcli/std/providers/router_provider"

describe "router provider" do
  use_natural_assertions

  Given(:app) { double(:App, path: double(:Path)) }
  Given(:provider) { MVCLI::RouterProvider.new }
  Given { provider.stub(:app) { app } }

  describe "creating the default router" do
    Given(:command) { double(:Command, :argv => ['foo']) }
    When(:router) { provider.value }
    When { router.stub(:actions) { double(:Actions, :new => true) } }
    context "when the routes file is in the standard place" do
      Given { app.path.stub(:read) { 'match "foo" => -> {}' } }
      Given { app.path.stub(:to_s) { 'routes.rb' } }

      Then { router[command] }
    end
  end
end
