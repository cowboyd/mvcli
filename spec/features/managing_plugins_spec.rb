require "spec_helper"

describe "installing a plugin", :announce do
  before { @timeout = 60 }
  When { r "trivium install plugin trivium-timing #{options}" }
  Invariant { trivial_timing == ['1s'] }
  Given(:fixtures) { Pathname(__FILE__).dirname.join('')}

  context "from a directory" do
    Given(:options) { "--path #{fixture 'plugins/timing-plugin'}" }
    Then { plugin_list == ['trivium-timing'] }
  end
  context "from a .gem file" do
    Given(:options) { "--path #{fixture 'plugins/trivium-timing.gem'}" }
    Then { plugin_list == ['trivium-timing'] }
  end
  context "from git" do
    Given(:options) { "--git file://fixtures/plugins/timing-plugin.git" }
    Then { plugin_list == ['trivium-timing'] }
  end

  context "from a rubygems server" do
    Given(:options) { }
  end

  def plugin_list
    r "trivium show plugins"
    all_stdout.split "\n"
  end

  def trivial_timing
    return ['1s']
    r "trivium time"
    all_stdout
  end
end
