require "mvcli/erb"

class MVCLI::Controller
  attr_reader :params

  def initialize(name, method, params)
    @name, @method, @params = name, method, params
  end

  def call(command)
    response = send @method
    filename = "views/#{@name}/#{@method}.txt.erb"
    compiler = MVCLI::ERB.new
    template = compiler.compile app.path.read(filename), app.path.to_s(filename)
    template.call response, command.output
    return 0
  end
end
