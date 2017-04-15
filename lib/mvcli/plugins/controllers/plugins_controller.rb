class MVCLI::PluginsController < MVCLI::Controller
  requires :cortex, :argv, :bundle

  def install
    @installation = bundle.replace params[:name], form.attributes
    respond_with @installation
  end

  def index
    @plugins = bundle.plugins
    respond_with @plugins
  end

  def respond_with(response, options = {})
    response
  end

end
