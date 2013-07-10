require "mvcli/form"
require "active_support/inflector/methods"

class MVCLI::Form::Input
  def initialize(name, target, options = {}, &block)
    @decoders = []
    @handler = handler(target).new name, target, options, &block
  end

  def decode(&block)
    @handler.decode &block
  end

  def value(source, context = nil, &transform)
    transform ||= ->(v) { v }
    @handler.value source, context, &transform
  end

  def handler(target)
    target.is_a?(Array) ? ListTarget : Target
  end

  class Target
    def initialize(name, target, options = {}, &block)
      @name, @options = name, Map(options)
      @decoders = []
      if block_given?
        @decoders << block
      end
    end

    def decode(&block)
      @decoders << block
    end


    def value(source, context = nil, &transform)
      transform.call decoded source, context
    end

    def decoded(source, context)
      if value = [source[@name]].flatten.first
        @decoders.reduce(value) do |value, decoder|
          decoder.call value
        end
      else
        default context
      end
    end

    def default(context)
      value = @options[:default]
      if value.respond_to?(:call)
        if context
          context.instance_exec(&value)
        else
          value.call
        end
      else
        value
      end
    end
  end

  class ListTarget < Target
    include ActiveSupport::Inflector

    def value(source, context = nil, &transform)
      source = Map(source)
      list = [source[singularize @name]].compact.flatten.map do |value|
        super({@name => value}, context, &transform)
      end.compact
      list.empty? ? [transform.call(default(context))].compact.flatten : list
    end
  end

end
