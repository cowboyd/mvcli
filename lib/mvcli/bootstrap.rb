require "mvcli/provisioning"

module MVCLI
  module Bootstrap
    requires :app

    def bootstrap(options = {}, &block)
      Scope.new(Map options) do |scope|
        scope.evaluate({cortex: cortex}, &block)
      end
    end

    def cortex
      Cortex.new do |cortex|
        Core.each do |cls|
          cortex << cls
        end
        #discover plugins here
      end
    end
  end
end
