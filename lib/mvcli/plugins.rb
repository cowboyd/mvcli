require "mvcli/core"

module MVCLI
  class Plugins < MVCLI::Core
    requires :bundle, :cortex
    self.path = File.expand_path '../plugins', __FILE__
    self.namespace = ::MVCLI
    self.identifier = 'mvcli-plugins'

    def activate!
      bundle.activate!
      Core.drain do |cls|
        core = cls.new if cls.path
        core.activate!
        cortex << core
      end
    end
  end
end
