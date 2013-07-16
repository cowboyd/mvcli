class MVCLI::Controller
  attr_reader :params

  def initialize(params = {}, app = nil)
    @params = params
    @app = app
  end
end
