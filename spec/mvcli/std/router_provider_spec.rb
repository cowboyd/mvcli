require "spec_helper"
require "mvcli/std/router_provider"

describe "router provider" do
  use_natural_assertions

  Given(:app) { double(:App, path: double(:Path)) }
  Given(:provider) { MVCLI::RouterProvider.new }
  Given { provider.stub(:app) { app } }

  describe "creating the default router" do
    Given(:command) { double(:Command, :argv => ['foo']) }
    When(:router) { provider.value }
    context "when the routes file is in the standard place" do
      Given { app.path.stub(:read) { 'match "foo" => proc {}' } }
      Given { app.path.stub(:to_s) { 'routes.rb' } }

      Then { router[command] }
    end
  end
end
