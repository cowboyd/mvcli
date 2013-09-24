require "mvcli/form"

class MVCLI::PluginsController < MVCLI::Controller
  requires :cortex, :argv

  def install
    template = cortex.read :form, "plugins/install"
    form = template.new argv.options
    form.validate!
    form.value
    model = cortex.read :model, "plugins/installation"
    model.new form
  end
end
