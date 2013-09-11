module MVCLI
  class Middleware
    def initialize
      @apps = []
    end

    def call(command, apps = @apps)
      app, *rest = apps
      if app
        app.call(command) do |yielded|
          yielded ||= command
          call yielded, rest
        end
      else
        return 0
      end
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

  end
end
