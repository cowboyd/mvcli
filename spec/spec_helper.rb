require "mvcli"
require "aruba/api"
require "rspec-given"

Dir[Pathname(__FILE__).dirname.join("support/**/*.rb")].each { |f| require f }


RSpec.configure do |config|
  Given.use_natural_assertions
  config.color_enabled = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include ArubaHelper, :example_group => {
    :file_path => /spec\/features/
  }
end
