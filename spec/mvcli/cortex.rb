require "mvcli/core"

module MVCLI
  class Cortex
    def initialize
      @cores = []
    end

    def <<(core)
      core.tap do
        @cores << core
      end
    end

    def exists?(extension_point, extension_name)
      @cores.detect {|core| core.exists? extension_point, extension_name }
    end

    def read(extension_point, extension_name)
      if core = exists?(extension_point, extension_name)
        core.read extension_point, extension_name
      else
        fail MVCLI::ExtensionNotFound, "unable to find #{extension_point} '#{extension_name}'"
      end
    end
  end
end
