require "map"
require "mvcli/path"
require "mvcli/provisioning"

module MVCLI
  class ExtensionNotFound < StandardError; end
  class InvalidPath < StandardError; end

  class Core

    requires :loader
    attr_accessor :path, :name, :namespace

    def initialize(options = {})
      options = Map options
      @path = options[:path]
      @name = options[:name]
      @namespace = options[:namespace]
    end

    def activate!
    end

    def path
      path = @path || self.class.path
      fail InvalidPath, "core `#{name}` cannot have a nil path" unless path
      path.is_a?(MVCLI::Path) ? path : MVCLI::Path.new(path.to_s)
    end

    def namespace
      @namespace || self.class.namespace || enclosing_namespace || Object
    end

    def name
      @name || self.class.identifier || self.class.name.gsub('::', '-').downcase unless namespace == Object
    end

    def version
      spec = Gem::Specification.load path.nearest('.gemspec$').to_s
      spec.version
    end

    def exists?(extension_type, name)
      loader.exists? path, extension_type, name
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
      include Enumerable
      attr_accessor :path, :identifier, :namespace, :version

      def inherited(base)
        ::MVCLI::Core << base
      end

      def all
        @all ||= []
      end

      def <<(base)
        all << base
      end

      def each(&visitor)
        all.each &visitor
      end

      def drain(&visitor)
        each &visitor
        all.clear
      end
    end

    class Std < self
      self.path = Pathname(__FILE__).dirname.join 'std'
      self.namespace = MVCLI
    end
  end
end
