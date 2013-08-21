require "map"

module MVCLI
  class ExtensionNotFound < StandardError; end

  class Core
    attr_reader :namespace

    def initialize(options = {})
      options = Map options
      fail ArgumentError, "missing required option :path" unless path = options[:path]
      @path = options[:path]
      @namespace = options[:namespace] || Object
    end

    def exists?(extension_type, name)
      @path.exists? extension_type, name
    end

    def read(extension_type, name, options = {})
      unless exists? extension_type, name
        fail ExtensionNotFound, "unable to locate #{extension_type} '#{name}'"
      end
      this = self
      @path.read(self.namespace, extension_type, name).tap do |ext|
        [ext, ext.singleton_class].each do |cls|
          cls.send(:define_method, :core) { this } if cls.respond_to?(:define_method, true)
        end
      end
    end
  end
end
