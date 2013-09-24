class MVCLI::Plugins::InstallationModel
  requires :config

  def initialize(form)
    @form = form
  end

  def name
    gemspec.name
  end

  def version
    gemspec.version
  end

  def location
    @form.path
  end

  def gemspec
    gemspec = Gem::Specification.load Dir[@form.path.join('*.gemspec')].first
    config.directory "plugins" do |dir|
      target = dir.join(gemspec.name)
      FileUtils.rm_rf target
      target.make_symlink location
      Gem.paths.path.unshift dir.to_s
      request = Gem::RequestSet.new *gemspec.dependencies
      request.resolve
      request.install_into dir
    end
    return gemspec
  end
end
