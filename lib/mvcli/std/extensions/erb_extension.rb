require "mvcli/erb"
require "active_support/inflector"
class MVCLI::ERBExtension
  include ActiveSupport::Inflector

  def to_path(name, extension_type)
    check! extension_type
    "#{pluralize extension_type}/#{name}.txt.erb"
  end

  def define(name, bytes, extension_type, namespace)
    check! extension_type
    erb = MVCLI::ERB.new
    erb.compile bytes, to_path(name, extension_type)
  end

  private

  def check!(extension_type)
    if extension_type.to_s != "template"
      fail ArgumentError, "invalid extension type '#{extension_type}' for ERB"
    end
  end
end
