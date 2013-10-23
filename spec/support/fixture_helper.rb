module FixtureHelper
  def fixture(path)
    Pathname(__FILE__).dirname.join('../fixtures').join path
  end
end
