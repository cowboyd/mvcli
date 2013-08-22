require "map"
require "mvcli/path"

module MVCLI
  class ExtensionNotFound < StandardError; end

  class Core
    attr_reader :loader
    attr_reader :namespace
    attr_reader :path

    def initialize(options = {})
      options = Map options
      @path = options[:path] or fail ArgumentError
      @loader = options[:loader] or fail ArgumentError
      @namespace = options[:namespace] || Object
    end

    def exists?(extension_type, name)
      @loader.exists? @path, extension_type, name
    end

    def read(extension_type, name, options = {})
      unless exists? extension_type, name
        fail ExtensionNotFound, "unable to locate #{extension_type} '#{name}'"
      end
      this = self
      @loader.read(path, namespace, extension_type, name).tap do |ext|
        [ext, ext.singleton_class].each do |cls|
          cls.send(:define_method, :core) { this } if cls.respond_to?(:define_method, true)
        end
      end
    end
  end
end
