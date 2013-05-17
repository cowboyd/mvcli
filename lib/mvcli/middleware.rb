module MVCLI
  class Middleware
    def initialize
      @apps = []
    end

    def call(command)
      invoke command, 0
    end

    def [](idx)
      @apps[idx]
    end

    def []=(idx, app)
      @apps[idx] = app
    end

    def <<(app)
      @apps << app
    end

    private

    def invoke(command, index)
      if app = @apps[index]
        app.call(command) do |c|
          if @apps[index + 1]
            c ||= command
            invoke c, index + 1
          end
        end
      else
        return 0
      end
    end
  end
end
