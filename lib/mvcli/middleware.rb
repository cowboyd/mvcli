module MVCLI
  class Middleware
    def initialize
      @apps = []
      yield self if block_given?
    end

    def call(command, apps = @apps, &block)
      app, *rest = apps + [block].compact
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

    def length
      @apps.length
    end
  end
end
