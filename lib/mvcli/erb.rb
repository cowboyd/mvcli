require "erb"

module MVCLI
  class ERB
    def initialize
      @compiler = ::ERB::Compiler.new("<>")
      @compiler.pre_cmd = [""]
      @compiler.put_cmd = "@_erbout <<"
      @compiler.insert_cmd = "@_erbout <<"
      @compiler.post_cmd = ["nil"]
    end

    def compile(string, filename = '(erb)')
      code, enc = @compiler.compile string
      Template.new code, enc, filename
    end

    class Template
      def initialize(code, enc, filename)
        @code, @enc, @filename = code, enc, filename
      end

      def call(context, output)
        binding = context.instance_eval do
          @_erbout = output
          Kernel.binding
        end
        eval @code, binding, @filename, 1
      ensure
        context.remove_instance_variable(:@_erbout)
      end

      def to_proc
        proc do |context, output|
          call context, output
        end
      end
    end
  end
end
