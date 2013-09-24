require "spec_helper"

describe "installing a plugin", :announce do
  before { @timeout = 60 }
  When { r "trivium install plugin #{options}" }
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
    Given(:options) { "trivium-timing" }
  end

  def plugin_list
    []
  end

  def trivial_timing
    r "trivium time"
    all_stdout
  end
end
