require "spec_helper"
require "mvcli/router"

describe "MVCLI::Router" do
  Given(:Router) {MVCLI::Router}
  Given(:actions) {mock(:Actions)}
  Given(:router) {self.Router.new actions}

  context "without any routes" do
    When(:result) {invoke}
    Then {result.should have_failed self.Router::RoutingError}
  end

  context "when an invalid root is mapped" do
    When(:result) {router.root :wat => :tf?}
    Then {result.should have_failed}
  end

  context "with its root mapped to a single verb" do
    Given do
      actions.stub(:[]).with('logins#create') do
        proc do |command|
          @login = command
        end
      end
    end
    Given {router.root :to => 'logins#create', :via => :login}
    When {invoke 'login'}
    Then {@login.argv.should eql ['login']}

    context "when a command comes in for an unmapped verb" do
      When(:result) {invoke 'fwiff'}
      Then {result.should have_failed self.Router::RoutingError}
    end
    context "and a second verb is mapped to the the root" do
      Given do
        actions.stub(:[]).with('logins#destroy') {proc {|c| @logout = c}}
      end
      Given {router.root :to => 'logins#destroy', :via => :logout}
      context "when I access via the original verb" do
        Given {invoke 'logout' }
        Then {@logout.should_not be_nil}
        And {@logout.argv.should eql ['logout']}
      end
    end
  end

  context "with its root mapped without a specific verb" do
    Given do
      actions.stub(:[]).with('something#show') {proc {|c|@something = c}}
    end
    Given {router.root :to => 'something#show'}
    When {invoke 'help'}
    Then {@something.argv.should eql ['help']}
  end

  def invoke(*args)
    router.call mock(:Command, :argv => args)
  end
end
