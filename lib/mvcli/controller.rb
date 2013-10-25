require "mvcli/erb"
require "mvcli/form"

class MVCLI::Controller
  requires :command, :cortex, :argv
  attr_reader :params

  def initialize(name, method, params)
    @name, @method, @params = name, method, params
  end

  def call(command)
    response = send @method
    template = cortex.read :template, "#{@name}/#{@method}"
    template.call response, command.output
    return 0
  end

  def form
    template = cortex.read :form, "#{@name}/#{@method}"
    form = template.new argv.options
    form.validate!
    form
  end
end
