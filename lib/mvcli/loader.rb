require "active_support/inflector/methods"

module MVCLI
  class Loader
    include ActiveSupport::Inflector

    def load(type, name, *args, &block)
      constantize(camelize("#{name}_#{type}")).new(*args, &block)
    end
  end
end
