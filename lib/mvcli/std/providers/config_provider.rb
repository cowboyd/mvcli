require 'fileutils'

class MVCLI::ConfigProvider
  requires :app

  def self.value
    new
  end

  attr_reader :home

  def initialize
    @home = find_or_create "#{ENV['HOME']}/.#{app.name}"
  end

  def directory(name)
    pathname = find_or_create @home.join name
    yield pathname if block_given?
    return pathname
  end

  private

  def find_or_create(path)
    Pathname(path.to_s).tap do |path|
      FileUtils.mkdir_p path.to_s unless path.exist?
    end
  end
end
