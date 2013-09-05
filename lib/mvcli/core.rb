require "map"
require "mvcli/path"
require "mvcli/provisioning"

module MVCLI
  class ExtensionNotFound < StandardError; end
  class InvalidPath < StandardError; end

  class Core
    requires :loader
    attr_accessor :path, :namespace

    def initialize(options = {})
      options = Map options
      @path = options[:path]
      @namespace = options[:namespace]
    end

    def path
      path = @path || self.class.path
      fail InvalidPath, "core cannot have a nil path" unless path
      path.is_a?(String) ? MVCLI::Path.new(path) : path
    end

    def namespace
      @namespace || self.class.namespace || enclosing_namespace || Object
    end

    def exists?(extension_type, name)
      loader.exists? @path, extension_type, name
    end

    def read(extension_type, name, options = {})
      unless exists? extension_type, name
        fail ExtensionNotFound, "unable to locate #{extension_type} '#{name}'"
      end
      this = self
      loader.read(path, extension_type, name, namespace).tap do |ext|
        [ext, ext.singleton_class].each do |cls|
          cls.send(:define_method, :core) { this } if cls.respond_to?(:define_method, true)
        end
      end
    end

    private

    def enclosing_namespace
      if self.class != MVCLI::Core && name = self.class.name
        components = name.split('::')[0..-2]
        unless components.empty?
          eval components.join('::')
        end
      end
    end

    class << self
      attr_accessor :path, :namespace
    end
  end
end
