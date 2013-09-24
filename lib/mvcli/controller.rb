require "mvcli/erb"

class MVCLI::Controller
  requires :command, :cortex
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
end
