require "spec_helper"
require "mvcli/loader"

describe "MVCLI::Loader" do

  Given {class ::TotallyAwesomeController; end}
  Given(:loader) {MVCLI::Loader.new '/path/to/app'}
  Given {loader.stub(:require) {true}}
  context "loading a controller in the global namespace" do
    When(:controller){loader.load :controller, 'totally_awesome'}
    Then {controller.should be_instance_of TotallyAwesomeController}
  end
end
