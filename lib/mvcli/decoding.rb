require "map"

module MVCLI::Decoding
  def self.[](type)
    type.mvcli_decoder
  end

  class Decoder
    def initialize(&block)
      @block = block || lambda {|s| s}
    end

    def call(string)
      if block_given?
        yield @block.call string
      else
        @block.call string
      end
    end
  end

  class ArrayDecoder < Decoder
    def call(array, &block)
      if block
        array.map(&@block).map(&block)
      else
        array.map &@block
      end
    end
  end

  class ::Object
    def self.mvcli_decoder
      Decoder.new
    end
  end

  class ::Integer
    def self.mvcli_decoder
      Decoder.new do |string|
        Integer(string)
      end
    end
  end

  class ::Array
    def mvcli_decoder
      decoder = first && first.respond_to?(:mvcli_decoder) ? first.mvcli_decoder : Object.mvcli_decoder
      ArrayDecoder.new do |element, &block|
        decoder.call element, &block
      end
    end
  end

  class ::String
    def mvcli_decoder
      format = TextFormat.new(self)
      Decoder.new do |string|
        format.call string
      end
    end
  end

  class TextFormat
    attr_reader :format

    def initialize(format)
      @format = format
      @names =  @format.gsub(/(\[|\])/, '').split(':').map(&:downcase)
    end

    def call(string)
      Enrich.new Hash[@names.zip string.split(':')]
    end

    class Enrich
      attr_reader :source

      def initialize(source)
        @source = Map source
        @enrichments = Map.new do |h,k|
          h[k] = []
        end
      end

      def [](key)
        @enrichments[key].reduce @source[key] do |value, enrichment|
          enrichment.call value
        end
      end

      def keys
        @source.keys
      end

      def values
        values_at *keys
      end

      def values_at(*keys)
        keys.reduce([]) do |values, key|
          values.tap do
            values << self[key]
          end
        end
      end

      def method_missing(name, *args, &block)
        return super unless respond_to? name
        if block_given?
          @enrichments[name] << block
          self
        else
          self[name]
        end
      end

      def respond_to?(name)
        super || @source.respond_to?(name)
      end
    end
  end
end
