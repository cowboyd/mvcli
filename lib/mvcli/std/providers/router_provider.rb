require "mvcli/router"

module MVCLI
  class RouterProvider
    requires :app

    def value
      builder = Router::DSL.new
      builder.instance_eval app.path.read('routes.rb'), app.path.to_s('routes.rb'), 1
      return builder.router
    end
  end
end
