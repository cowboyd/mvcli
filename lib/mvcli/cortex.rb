require "mvcli/core"

module MVCLI
  class Cortex
    include Enumerable

    def initialize
      @cores = []
      yield self if block_given?
    end

    def <<(core)
      tap do
        @cores << core
      end
    end

    def each(&block)
      @cores.each &block
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
