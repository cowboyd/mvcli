require "mvcli/plugins/installation"
class MVCLI::BundleProvider
  requires :config

  def value
    self
  end

  def activate!
    installation.activate!
  end

  def replace(name, options = {})
    installation.replace_gem name, options
    installation.install!
    installation.plugins.find { |p| p.name == name }
  end

  def remove(gem_name)
    installation.remove_gem gem_name
    installation.install!
  end

  def plugins
    installation.plugins
  end

  def installation
    @installation ||= MVCLI::Plugins::Installation.new config.directory("plugins")
  end
end
