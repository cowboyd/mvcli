require "map"
require "active_support/inflector"

class MVCLI::Argv
  attr_reader :arguments, :options

  def initialize(argv, switches = [], objects = Map.new)
    @switches = switches.map(&:to_s)
    @objects = Map objects
    @arguments, @options = scan argv
  end

  def scan(argv, arguments = [], options = Map.new)
    current, *rest = argv
    case current
    when nil
      [arguments, options]
    when /^--(\w[[:graph:]]+)=([[:graph:]]+)$/
      scan rest, arguments, merge(options, $1, $2)
    when /^--no-(\w[[:graph:]]+)$/
      scan rest, arguments, merge(options, $1, false)
    when /^--(\w[[:graph:]]+)$/, /^-(\w)$/
      key = underscore $1
      if switch? key
        scan rest, arguments, merge(options, key, true)
      elsif rest.first =~ /^-/
        scan rest, arguments, merge(options, key)
      elsif object? key
        value, *rest = rest
        scan rest, arguments, merge(options, key, scan_object(key, value))
      else
        value, *rest = rest
        scan rest, arguments, merge(options, key, value)
      end
    else
      scan rest, arguments + [current], options
    end
  end

  def switch?(key)
    @switches.member? underscore key
  end

  def object?(key)
    @objects.member? underscore key
  end

  def scan_object(name, value)
    keys = @objects[name]
    Map Hash[keys.zip value.split ':']
  end

  def merge(options, key, value = nil)
    key = underscore key
    values = options[key] || []
    options.merge(key => values + [value].compact)
  end

  def underscore(string)
    string.gsub('-','_')
  end
end
