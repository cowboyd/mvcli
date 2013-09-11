require "spec_helper"
require "mvcli/middleware"

describe "MVCLI::Middleware" do
  before do
    @middleware = MVCLI::Middleware.new
    @command = double(:Command)
  end

  it "runs perfectly fine without any apps" do
    @middleware.call(@command).should eql 0
  end

  describe "with a single app" do
    before do
      @app = proc do |command|
        @called = command
      end
      @middleware << @app
      @middleware.call @command
    end
    it "calls it" do
      @called.should eql @command
    end
  end

  describe "with a couple apps" do
    before do
      @sequence = []
      @commands = []
      @middleware << proc do |command, &block|
        @commands << command
        @sequence << "first.before"
        block.call
        @sequence << "first.after"
      end
      @middleware << proc do |command, &block|
        @commands << command
        @sequence << "second"
      end
      @middleware.call @command
    end
    it "passes the command to all the apps" do
      @commands.should eql [@command, @command]
    end
    it "calls the first app *around* the second app" do
      @sequence.should eql ["first.before", "second", "first.after"]
    end

    describe "if the first app does not yield" do
      before do
        @sequence.clear
        @middleware[0] = Proc.new {}
        @middleware.call @command
      end
      it "never calls the second app" do
        @sequence.should eql []
      end
    end
  end

  describe "with an app that yields even though there is no next app" do
    before do
      app = Object.new
      def app.call(command)
        yield
      end
      @middleware << @app
    end
    it "runs successfully" do
      @middleware.call(@command).should eql 0
    end
  end
end
