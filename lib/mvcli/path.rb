require "pathname"

module MVCLI
  class Path
    def initialize(base)
      @base = Pathname(base.to_s)
    end

    def exists?(path)
      @base.join(path).exist?
    end

    def read(path)
      @base.join(path).read
    end

    def join(path)
      self.class.new @base.join path
    end

    def to_s(path = nil)
      path.nil? ? @base.to_s : @base.join(path).to_s
    end
  end
end
