require "active_support/inflector/methods"

module MVCLI
  class Loader
    include ActiveSupport::Inflector

    def load(type, name, *args, &block)
      constantize(camelize("#{name}_#{type}")).new(*args, &block)
    end

    def exists?(path, extension_type, name)
      path.exists? "#{pluralize extension_type}/#{name}_#{extension_type}.rb"
    end

    def read(path, extension_type, name, namespace = Object)
      filename = "#{pluralize extension_type}/#{name}_#{extension_type}.rb"
      bytes = path.read filename
      eval bytes, blank_slate, filename, 1
      components = [namespace.name, classify("#{name}_#{extension_type}")]
      components.shift if namespace == Object
      lookup components.join('::'), filename
    end

    private

    def blank_slate
      BasicObject.new.instance_eval { Kernel.binding }
    end

    def lookup(class_name, filename)
      constantize class_name
    rescue NameError
      fail LoadError, "expected #{filename} to define #{class_name}"
    end
  end
end
