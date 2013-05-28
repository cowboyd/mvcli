require "spec_helper"
require "mvcli/loader"

describe "MVCLI::Loader" do
  Given do
    class ::TotallyAwesomeController
      attr_reader :params
      attr_reader :block
      def initialize(params, &block)
        @params = params
        @block = block
      end
    end
  end
  Given(:loader) {MVCLI::Loader.new}

  context "when a controller load is requested in the global  namespace" do
    When(:controller){loader.load(:controller, 'totally_awesome', {:foo => :bar}) {'whee!'}}
    Then {controller.should be_instance_of TotallyAwesomeController}
    And {controller.params.should eql ({:foo => :bar})}
    And {controller.block.call.should eql "whee!"}
  end
end
