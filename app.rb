require "mvcli/app"

module MVCLI
  class CLI < ::MVCLI::App
    self.path = Pathname(__FILE__).dirname
  end
end
