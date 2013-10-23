require "mvcli/plugins"
class MVCLI::Plugins::Installation

  def initialize(dir)
    @dir = Pathname(dir.to_s)
    @changes = []
  end

  def specs
    if lockfile
      lockfile.specs
    else
      []
    end
  end

  def dependencies
    gemfile.dependencies
  end

  def plugins
    specs.select do |spec|
      gemfile.dependencies.detect { |dep| dep.name == spec.name }
    end
  end

  def replace_gem(name, *options)
    gemfile.dependencies.reject! { |dep| dep.name == name }
    dep, *rest = gemfile.gem name, *options
    @changes << name
    return dep
  end

  def activate!
    require activatefile_path
  end

  def install!
    fail "This installation has already been installed if" if gemfile_path.exist?
    require "bundler"
    gemfile_path.open "w" do |file|
      file.puts "source 'https://rubygems.org'"
      gemfile.dependencies.each do |dep|
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
    activatefile_path.open "w" do |file|
      file.puts "require #{setupfile_path.to_s.inspect}"
      gemfile.dependencies.each do |dep|
        require_names = dep.autorequire || [dep.name]
        require_names.each do |name|
          file.puts "require #{name.inspect}"
        end
      end
    end
    bundle!
  end

  def bundle!
    updates = @changes.reduce({}) do |h,k|
      h.tap { h[k] = true }
    end
    path = Bundler.settings[:path]
    original_definition_method = Bundler.method(:definition)
    Bundler.with_clean_env do
      ENV['BUNDLE_GEMFILE'] = gemfile_path.to_s
      definition = gemfile.to_definition(lockfile, updates)
      Bundler.settings[:path] = @dir.join('bundle').to_s
      Dir.chdir @dir do
        Bundler.define_singleton_method(:definition) { definition }
        Bundler::Installer.install @dir, definition, standalone: [], "update" => true
      end
    end
  ensure
    Bundler.define_singleton_method(:definition, &original_definition_method)
    Bundler.settings[:path] = path
  end

  private

  def gemfile
    @gemfile ||= Bundler::Dsl.new.tap do |builder|
      builder.eval_gemfile gemfile_path if gemfile_path.exist?
    end
  end

  def lockfile
    require 'bundler'
    Bundler::LockfileParser.new(lockfile_path.read) if lockfile_path.exist?
  end

  def gemfile_path
    @dir.join 'Gemfile'
  end

  def lockfile_path
    @dir.join 'Gemfile.lock'
  end

  def setupfile_path
    @dir.join 'bundle/bundler/setup'
  end

  def activatefile_path
    @dir.join 'activate.rb'
  end
end
