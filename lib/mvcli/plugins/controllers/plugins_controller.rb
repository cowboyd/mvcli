class MVCLI::PluginsController < MVCLI::Controller
  requires :cortex, :argv, :bundle

  def install
    @installation = bundle.replace params[:name], form.attributes
    respond_with @installation
  end

  def uninstall
    @installation = bundle.remove params[:name]
    respond_with @installation
  end

  def index
    @plugins = bundle.plugins
    respond_with @plugins
  end

  ## TODO
  ## move this elsewhere

  def form
    template = cortex.read :form, "#{@name}/#{@method}"
    form = template.new argv.options
    form.validate!
    form
  end

  def respond_with(response, options = {})
    response
  end

end
