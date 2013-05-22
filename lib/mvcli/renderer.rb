require 'mvcli/erb'

module MVCLI
  class Renderer
    def initialize(root)
      @root = root
    end

    def render(output, path, context)
      filename = @root.join('app/views', path + '.txt.erb').to_s
      compiler = MVCLI::ERB.new
      template = compiler.compile File.read(filename), filename
      template.call(context, output)
    end
  end
end
