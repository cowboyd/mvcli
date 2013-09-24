require "mvcli/core"

module MVCLI
  class Plugins < MVCLI::Core
    requires :config
    self.path = File.expand_path '../plugins', __FILE__
    self.namespace = ::MVCLI
    self.identifier = 'mvcli-plugins'

    def activate
      config.directory :plugins do |path|
        Gem.paths.path.unshift path.to_s
      end
    end
  end
end
