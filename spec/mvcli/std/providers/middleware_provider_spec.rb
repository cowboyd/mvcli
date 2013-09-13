require "spec_helper"
require "mvcli/std/providers/middleware_provider"

describe "building middleware" do
  use_natural_assertions

  When(:middleware) { MVCLI::MiddlewareProvider.new.value }
  Then { middleware.should_not have_failed }
  And { middleware.length == 2}
end
