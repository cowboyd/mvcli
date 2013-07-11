require "spec_helper"
require "mvcli/router"

describe "MVCLI::Router" do
  Given(:Router) {MVCLI::Router}
  Given(:actions) {mock(:Actions)}
  Given(:router) {self.Router.new actions}
  Given do
    actions.stub(:[]) do |action|
      @action = action
      ->(command, bindings) {@command = command; @bindings = bindings}
    end
  end

  context "without any routes" do
    When(:result) {invoke}
    Then {result.should have_failed self.Router::RoutingError}
  end

  context "with a route matched to an action" do
    Given {router.match 'login' => 'logins#create'}
    When {invoke 'login'}
    Then {@action.should eql 'logins#create'}
    And {@command.should_not be_nil}
    Then {@command.argv.should eql ['login']}
  end

  context "when there are command line options, it does not interfere" do
    Given {router.match 'login' => 'logins#create'}
    When {invoke 'login --then --go-away -f 6 -p'}
    Then {@command.should_not be_nil}
  end

  context "with a route matched to a block" do
    Given {router.match bam: ->(command) {@command = command}}
    When {invoke 'bam'}
    Then {@command.argv.should eql ['bam']}
  end

  context "with a route with captures" do
    Given {router.match 'show loadbalancer :id' => 'loadbalancers#show'}
    When {invoke 'show loadbalancer 6'}
    Then {@action.should eql 'loadbalancers#show'}
    And {@command.argv == ['show' 'loadbalancer' '6']}
    And {@bindings[:id].should eql '6'}
  end

  context "with macros" do
    Given { router.macro /(-h|--help) (.*)/ => "help \\2" }
    Given { router.match "help me" => "help#me"}
    When { invoke "--help me" }
    Then { @action.should eql 'help#me' }
  end

  def invoke(route = '')
    router.call mock(:Command, :argv => route.split(/\s+/))
  end
end
