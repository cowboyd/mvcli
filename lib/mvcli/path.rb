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
  end
end
