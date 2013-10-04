require "spec_helper"

describe "installing a plugin" do
  before { @timeout = 60 }
  When { r "trivium install plugin trivium-timing --path #{fixture 'plugins/timing-plugin'}" }
  Given(:fixtures) { Pathname(__FILE__).dirname.join('') }

  Then { plugin_list == ['trivium-timing'] }
  And { trivial_timing == '1s'}

  describe "uninstalling the plugin" do
    When { r "trivium uninstall plugin trivium-timing" }
    Then { plugin_list == [] }
    describe "trying to invoke the command" do
      When(:result) { r "trivium time" }
      Then { result.should have_failed }
    end
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
