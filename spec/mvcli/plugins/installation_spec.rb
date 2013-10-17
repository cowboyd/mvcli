require "spec_helper"
require "mvcli/plugins/installation"

describe "building a new installation" do
  Given(:dir) { Pathname(Dir.tmpdir).join 'installation_spec' }
  Given { FileUtils.rm_rf dir.to_s }
  When(:installation) { MVCLI::Plugins::Installation.new dir }

  Then { installation.plugin_specs.empty? }
  Then { installation.specs.empty? }
  Then { installation.dependencies.empty? }

end
