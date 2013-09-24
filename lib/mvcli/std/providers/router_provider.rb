require "mvcli/router"

module MVCLI
  class RouterProvider
    requires :cortex

    def value
      builder = Router::DSL.new
      cortex.each do |core|
        if core.path.exists? 'routes.rb'
          builder.instance_eval core.path.read('routes.rb'), core.path.to_s('routes.rb'), 1
        end
      end
      return builder.router
    end
  end
end
