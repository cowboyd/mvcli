require "spec_helper"

describe "installing a plugin" do
  before { @timeout = 60 }
  When { r "trivium install plugin trivium-timing #{options}" }
  Given(:fixtures) { Pathname(__FILE__).dirname.join('')}

  context "from a directory" do
    Given(:options) { "--path #{fixture 'plugins/timing-plugin'}" }
    Then { plugin_list == ['trivium-timing'] }
    And { trivial_timing == '1s'}
  end

  def plugin_list
    r "trivium show plugins"
    all_stdout.split "\n"
  end

  def trivial_timing
    r "trivium time"
    all_stdout
  end
end
