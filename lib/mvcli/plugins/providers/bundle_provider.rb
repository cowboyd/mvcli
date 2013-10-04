class MVCLI::BundleProvider
  requires :config

  def value
    self
  end

  def activate!
    require activatefile if activatefile.exist?
  end

  def replace(name, options = {})
    require 'bundler'
    builder.dependencies.reject! { |dep| dep.name == name }
    dep, *rest = builder.gem name, options
    update! name
    write!
    return dep
  end

  def remove(gem_name)
    require 'bundler'
    dep = builder.dependencies.find { |d| d.name == gem_name }
    fail "#{gem_name} is not an installed plugin" unless dep
    builder.dependencies.reject! { |d| d == dep }
    update! gem_name
    write!
    return dep
  end

  def plugins
    lock.specs.select do |spec|
      builder.dependencies.detect { |dep| dep.name == spec.name }
    end
  end

  def gemfile
    dir.join('Gemfile').tap do |path|
      unless path.exist?
        path.open "wb" do |file|
          file.puts "source 'https://rubygems.org'"
        end
      end
    end
  end

  def lockfile
    dir.join 'Gemfile.lock'
  end

  def setupfile
    dir.join 'bundle/bundler/setup.rb'
  end

  def activatefile
    dir.join 'activate.rb'
  end

  def dir
    config.directory('plugins')
  end

  def builder
    @builder ||= Bundler::Dsl.new.tap do |builder|
      builder.eval_gemfile gemfile
    end
  end

  def lock
    require 'bundler'
    Bundler::LockfileParser.new lockfile.read
  end

  def write!
    gemfile.open "w" do |file|
      file.puts "source 'https://rubygems.org'"
      builder.dependencies.each do |dep|
        file << %|gem "#{dep.name}"|
        if req = dep.requirements_list.first
          file << %|, "#{req}"|
        end
        options = dep.source ? dep.source.options || {} : {}
        options = Hash[options.map { |k, v| [k,v.to_s]}]
        options.merge! "require" =>  dep.autorequire if dep.autorequire
        file << %|, #{options.inspect}|
        file << "\n"
      end
    end
    activatefile.open "w" do |file|
      file.puts "require #{setupfile.to_s.inspect}"
      builder.dependencies.each do |dep|
        require_names = dep.autorequire || [dep.name]
        require_names.each do |name|
          file.puts "require #{name.inspect}"
        end
      end
    end
  end

  def update!(name)
    path = Bundler.settings[:path]
    original_definition_method = Bundler.method(:definition)
    Bundler.with_clean_env do
      ENV['BUNDLE_GEMFILE'] = gemfile.to_s
      definition = builder.to_definition(lockfile, name => true)
      Bundler.settings[:path] = dir.join('bundle').to_s
      Dir.chdir dir do
        Bundler.define_singleton_method(:definition) { definition }
        Bundler::Installer.install dir, definition, standalone: [], "update" => true
      end
    end
  ensure
    Bundler.define_singleton_method(:definition, &original_definition_method)
    Bundler.settings[:path] = path
  end
end
