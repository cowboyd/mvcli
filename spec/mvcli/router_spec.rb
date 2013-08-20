require "spec_helper"
require "mvcli/router"

describe "MVCLI::Router" do
  use_natural_assertions

  Given(:Router) { MVCLI::Router }
  Given(:actions) { double(:Actions) }
  Given(:router) { self.Router.new actions }
  Given do
    actions.stub(:[]) do |action|
      @action = action
      ->(command, bindings) {@command = command; @bindings = bindings}
    end
  end

  def invoke(route = '')
    router.call double(:Command, :argv => route.split(/\s+/))
  end

  context "without any routes" do
    When(:result) { invoke }
    Then { result.should have_failed self.Router::RoutingError }
  end

  context "with a route matched to an action" do
    Given { router.match 'login' => 'logins#create' }
    When { invoke 'login' }
    Then { @action == 'logins#create' }
    And { not @command.nil? }
    Then { @command.argv == ['login'] }
  end

  context "when there are command line options, it does not interfere" do
    Given { router.match 'login' => 'logins#create' }
    When { invoke 'login --then --go-away -f 6 -p' }
    Then { not @command.nil? }
  end

  context "with a route matched to a block" do
    Given { router.match bam: ->(command) {@command = command} }
    When { invoke 'bam' }
    Then { @command.argv == ['bam'] }
  end

  context "with a route with captures" do
    Given { router.match 'show loadbalancer :id' => 'loadbalancers#show' }
    When { invoke 'show loadbalancer 6' }
    Then {@action == 'loadbalancers#show'}
    And { @command.argv == ['show', 'loadbalancer', '6'] }
    And { @bindings[:id] == '6' }
  end

  context "with macros" do
    Given { router.macro /(-h|--help) (.*)/ => "help \\2" }
    Given { router.match "help me" => "help#me"}
    When { invoke "--help me" }
    Then { @action == 'help#me' }
  end
end
