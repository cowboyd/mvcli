require "mvcli/app"
require "mvcli/plugins"
require "trivium/version"

module Trivium
  class App < MVCLI::App
    self.path = Pathname(__FILE__).dirname.join('app')
    self.identifier = 'trivium'
  end
end
