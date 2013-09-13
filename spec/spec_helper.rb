require "mvcli"
require "rspec-given"
require "aruba/api"

RSpec.configure do |config|
  Given.use_natural_assertions
  module ArubaHelper
    def mvcli(command)
      process = run "mvcli #{command}"
      status = process.stop nil
      fail process.stderr unless status == 0
    end
  end
  config.color_enabled = true
  config.include Aruba::Api, :example_group => {
    :file_path => /spec\/features/
  }
  config.include ArubaHelper, :example_group => {

  }

  config.before(:each) do
    @__aruba_original_paths = (ENV['PATH'] || '').split(File::PATH_SEPARATOR)
    ENV['PATH'] = ([File.expand_path('bin')] + @__aruba_original_paths).join(File::PATH_SEPARATOR)
  end

  config.after(:each) do
    ENV['PATH'] = @__aruba_original_paths.join(File::PATH_SEPARATOR)
  end
end
