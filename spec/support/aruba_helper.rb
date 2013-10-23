module ArubaHelper
  include Aruba::Api

  def r(command)
    run_simple File.expand_path("../../fixtures/bin/#{command}", __FILE__), true, @timeout
  end

  def self.included(base)
    base.before :each, :"disable-bundler" do
      unset_bundler_env_vars
    end

    base.before :each do
      @__aruba_original_paths = (ENV['PATH'] || '').split(File::PATH_SEPARATOR)
      ENV['PATH'] = ([File.expand_path('bin')] + @__aruba_original_paths).join(File::PATH_SEPARATOR)
      ENV['backtrace'] = 'true'
      set_env "HOME", File.expand_path(current_dir)
    end

    base.after :each do
      ENV['PATH'] = @__aruba_original_paths.join(File::PATH_SEPARATOR)
    end

    base.before :each do
      FileUtils.rm_rf(current_dir) unless example.metadata[:"no-clobber"]
    end

    base.before :each do
      @timeout = example.options[:timeout]
    end

    base.before :each, :puts do
      @puts = true
    end

    base.before :each, :"announce-cmd" do
      @announce_cmd = true
    end

    base.before :each, :"announce-dir" do
      @announce_dir = true
    end

    base.before :each, :"announce-stdout" do
      @announce_stdout = true
    end

    base.before :each, :"announce-stderr" do
      @announce_stderr = true
    end

    base.before :each, :"announce-env" do
      @announce_end = true
    end

    base.before :each, :announce do
      @announce_stdout = true
      @announce_stderr = true
      @announce_cmd = true
      @announce_dir = true
      @announce_env = true
    end

    base.before :each, :ansi do
      @aruba_keep_ansi = true
    end

    base.after :each do
      restore_env
    end
  end
end
