require "spec_helper"
require "mvcli/plugins/providers/bundle_provider"
require "bundler/ui"



describe "Bundle Provider" do
  # Given(:bundle) { MVCLI::BundleProvider.new }
  # Given(:dir) { Pathname(__FILE__).dirname.join('tmp/plugins') }
  # Given do
  #   bundle.stub(:dir) { dir }
  #   FileUtils.rm_rf dir.to_s
  #   FileUtils.mkdir_p dir.to_s
  # end
  # describe "replacing a gem in the bundle" do
  #   When { bundle.replace "trivium-timing", require: 'trivium-timing', path: File.expand_path('../../../../fixtures/plugins/timing-plugin', __FILE__) }
  #   When { bundle.replace "ref" }
  #   describe "activating the bundle" do
  #     When { bundle.activate! }
  #     Then { "it's in the classpath now" }
  #   end
  # end
end
