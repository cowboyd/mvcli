require "active_support/inflector/methods"

module MVCLI
  class Loader

    def initialize(extensions = {})
      @extensions = Map extensions
      @default_handler = DefaultHandler.new
    end

    def load(type, name, *args, &block)
      constantize(camelize("#{name}_#{type}")).new(*args, &block)
    end

    def exists?(path, extension_type, name)
      pathname = handler(extension_type).to_path name, extension_type
      path.exists? pathname
    end

    def read(path, extension_type, name, namespace = Object)
      pathname = handler(extension_type).to_path name, extension_type
      bytes = path.read pathname
      handler(extension_type).define name, bytes, extension_type, namespace
    end

    private

    def handler(extension_type)
      @extensions[extension_type] || @default_handler
    end

    class DefaultHandler
      include ActiveSupport::Inflector

      def to_path(name, extension_type)
        "#{pluralize extension_type}/#{name}_#{extension_type}.rb"
      end

      def define(name, bytes, extension_type, namespace)
        eval bytes, blank_slate, to_path(name, extension_type), 1
        components = [namespace.name, classify("#{name}_#{extension_type}")]
        components.shift if namespace == Object
        lookup components.join('::'), to_path(name, extension_type)
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
end
