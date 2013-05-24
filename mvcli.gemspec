# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mvcli/version'

Gem::Specification.new do |spec|
  spec.name          = "mvcli"
  spec.version       = MVCLI::VERSION
  spec.authors       = ["Charles Lowell"]
  spec.email         = ["cowboyd@thefrontside.net"]
  spec.description   = %q{MVC Framework for Building Command Line Apps}
  spec.summary       = %q{Local Apps. Remote Apps. They're all at your fingertips}
  spec.homepage      = "https://github.com/cowboyd/mvcli"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "map"
  spec.add_dependency "activesupport", ">= 3.0"
end
