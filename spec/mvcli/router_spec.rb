require "spec_helper"
require "mvcli/router"

describe "MVCLI::Router" do
  use_natural_assertions

  Given(:Router) { MVCLI::Router}
  Given(:routes) { self.Router::DSL.new }
  Given(:router) { routes.router }
  Given(:actions) { double(:Actions) }
  Given { actions.stub(:new) { |match, mapping| Map match: match, mapping: mapping } }
  Given { router.stub(:actions) { actions } }

  def invoke(route = '')
    router.call double(:Command, :argv => route.split(/\s+/))
  end

  context "without any routes" do
    When(:result) { invoke }
    Then { result.should have_failed self.Router::RoutingError }
  end

  context "with a route matched to an action" do
    Given { routes.match 'login' => 'logins#create' }
    When(:action) { invoke 'login' }
    Then { action.mapping == 'logins#create' }
  end

  context "when there are command line options, it does not interfere" do
    Given { routes.match 'login' => 'logins#create' }
    When(:action) { invoke 'login --then --go-away -f 6 -p' }
    Then { action.mapping == 'logins#create' }
  end

  context "with a route matched to a block" do
    Given { routes.match bam: ->(command) { command } }
    When(:action) { invoke 'bam' }
    Then { action.mapping.call('foo') == 'foo' }
  end

  context "with a route with captures" do
    Given { routes.match 'show loadbalancer :id' => 'loadbalancers#show' }
    When(:action) { invoke 'show loadbalancer 6' }
    Then { action.mapping == 'loadbalancers#show'}
    Then { action.match.bindings[:id] == '6' }
  end

  context "with macros" do
    Given { routes.macro /(-h|--help) (.*)/ => "help \\2" }
    Given { routes.match "help me" => "help#me"}
    When(:action) { invoke "--help me" }
    Then { action.mapping == 'help#me' }
  end
end
