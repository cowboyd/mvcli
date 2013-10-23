require "spec_helper"
require "mvcli/plugins/installation"

describe "building a new installation" do
  Given(:dir) { Pathname(Dir.tmpdir).join 'installation_spec' }
  Given { FileUtils.rm_rf dir.to_s; FileUtils.mkdir_p dir.to_s }
  When(:installation) { MVCLI::Plugins::Installation.new dir }

  Then { installation.plugins.empty? }
  Then { installation.specs.empty? }
  Then { installation.dependencies.empty? }

  describe "adding a requirement" do
    When { installation.replace_gem 'trivium-timing', "~> 1.0", path: fixture('plugins/timing-plugin').to_s }
    Then { installation.dependencies.map(&:name) == ['trivium-timing'] }
    describe "and then installing" do
      When { installation.install! }
      When(:plugins) { installation.plugins }
      Then { plugins.map { |p| "#{p.name} #{p.version}" } == ['trivium-timing 1.0.0'] }
      describe "and activating" do
        When { installation.activate! }
        Then { defined? Trivium }
      end
    end
  end
end
