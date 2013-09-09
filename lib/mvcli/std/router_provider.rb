require "mvcli/router"

module MVCLI
  class RouterProvider
    requires :app

    def value
      router = Router.new
      router.instance_eval app.path.read('routes.rb'), app.path.to_s('routes.rb'), 1
      return router
    end
  end
end
