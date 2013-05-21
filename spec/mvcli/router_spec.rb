require "spec_helper"
require "mvcli/router"

describe "MVCLI::Router" do
  Given(:Router) {MVCLI::Router}
  Given(:actions) {mock(:Actions)}
  Given(:router) {self.Router.new actions}
  Given {actions.stub(:[]) {|action| @action = action; ->(command) {@command = command}}}


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

  context "with a route matched to a block" do
    Given {router.match bam: ->(command) {@command = command}}
    When {invoke 'bam'}
    Then {@command.argv.should eql ['bam']}
  end

  context "with a route with dynamic segments" do
    Given {router.match 'show loadbalancer :name' => 'loadbalancers#show'}
    When(:result) {invoke 'show loadbalancer 6'}
  end

  def invoke(*args)
    router.call mock(:Command, :argv => args)
  end
end
