module MVCLI
  class Loader
    def initialize(path)
      @path = path
    end

    def load(type, name)
      pathname = "#{name}_#{type}"
      filename = File.join(@path, "app/#{type}s", pathname)
      require filename
      classname = pathname.capitalize.gsub(/_(\w)/) {|m| m[1].upcase}
      Object.const_get(classname).new
    end
  end
end
