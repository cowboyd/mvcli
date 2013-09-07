require "spec_helper"
require "mvcli/path"

describe "MVCLI::Path" do
  use_natural_assertions
  Given(:path) { MVCLI::Path.new(Pathname(__FILE__).dirname.join(File.basename __FILE__, '.rb')) }

  Then { path.exists? 'does/exist' }
  Then { not path.exists? 'does/not/exist' }
  Then { path.read('does/exist') == "Hello World"}
  Then { path.to_s('flim flam')  =~ %r{mvcli/spec/mvcli/path_spec/flim flam} }
end
