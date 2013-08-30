require "spec_helper"

describe "Cortex" do
  use_natural_assertions

  Given(:cortex) { MVCLI::Cortex.new }
end
