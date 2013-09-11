require "spec_helper"
require "mvcli/middleware"

describe "MVCLI::Middleware" do
  use_natural_assertions
  Given(:middleware) { MVCLI::Middleware.new }
  Given(:command) { double :Command }

  When { @result = middleware.call command }

  context "without any apps" do
    Then { @result == 0 }
  end

  context "with a single app" do
    Given do
      middleware << proc do |command|
        @called = command
      end
    end
    Then { @called == command }
  end

  context "with a couple of apps" do
    Given do
      @sequence = []
      @commands = []
      middleware << proc do |command, &block|
        @commands << command
        @sequence << "first.before"
        block.call
        @sequence << "first.after"
      end
      middleware << proc do |command, &block|
        @commands << command
        @sequence << "second"
      end
    end
    Then { @commands == [command, command] }
    Then { @sequence == ["first.before", "second", "first.after"] }

    context "when the first does not yield to the second" do
      Given { middleware[0] = Proc.new {} }
      Then { @sequence == [] }
    end
  end

  context "with a single app that yields even though there is no next app" do
    Given { middleware << proc {|c, &block| block.call } }
    Then { @result == 0 }
  end

  context "when invoked with a 'follow-on' app" do
    When(:result) { middleware.call(command) {|c| c} }
    Then { result == command }
  end
end
