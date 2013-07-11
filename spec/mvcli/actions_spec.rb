require "spec_helper"
require "mvcli/actions"

describe "MVCLI::Actions" do
  Given(:loader) {mock(:Loader)}
  Given(:renderer) {mock(:Renderer, :render => true)}
  Given(:actions) {MVCLI::Actions.new '/root', loader, renderer}

  context "when the loader cannot find an appropriate controller" do
    Given {loader.stub(:load) {fail LoadError}}
    When(:action) {actions['foo']}
    Then {action.should_not be_nil}

    context ".calling it" do
      When(:result) {action.call(mock(:Command))}
      Then {result.should have_failed LoadError}
    end
  end

  context "when the class exists" do
    Given(:output) {mock(:Output)}
    Given(:controller) {mock(:Controller)}
    Given {loader.stub(:load).with(:controller, 'foo', {}) {controller}}
    Given {controller.stub(:bar) {"the context"}}
    When {actions['foo#bar'].call(mock(:Command, :output => output), {})}
    Then {controller.should have_received(:bar)}
    And {renderer.should have_received(:render).with(output, 'foo/bar', 'the context')}
  end

  context "when the action is callable" do
    Given(:app) { ->(c) {} }
    Then { actions[app] == app }
  end
end
