require "mvcli/app"

module MVCLI
  class CLI < ::MVCLI::App
    self.path = File.expand_path '../app', __FILE__
  end
end
