require "spec_helper"
require "mvcli/router/pattern"

describe "MVCLI::Router::Pattern" do
  use_natural_assertions
  describe "with a simple input" do
    Given(:pattern) {compile "one two three"}
    context "when matched against unrelated content" do
      When(:match) {pattern.match %w(five six seven)}
      Then {!match.matches?}
      And {!match.exhaustive?}
      And {!match.partial?}
      And {!match.satisfied?}
    end
    context "when matched against the same content" do
      When(:match) {pattern.match %w(one two three)}
      Then {match.matches?}
      And {match.exhaustive?}
      And {match.partial?}
      And {match.satisfied?}

    end
    context "when matched against partially matching content" do
      When(:match) {pattern.match %w(one two)}
      Then {match.partial?}
      And {match.exhaustive?}
    end
    context "on an unexhausted sequence" do
      When(:match) {pattern.match %w(one two three four)}
      Then {!match.exhaustive?}
      And {match.partial?}
    end
  end
  describe "with variables" do
    Given(:pattern) {compile "one :one :two two "}
    context "on a matching sequence" do
      When(:match) {pattern.match %w(one 1 2 two)}
      Then {match.matches?}
      And {match.bindings[:one] == '1'}
      And {match.bindings[:two] = '2'}
    end
    context "on a partially matching sequence" do
      When(:match) {pattern.match %w(one 1)}
      Then {match.partial?}
      And {!match.matches?}
      And {match.bindings[:one] == "1"}
      And {match.bindings[:two] == nil}
    end
  end

  def compile(*args)
    MVCLI::Router::Pattern.new(*args)
  end
end
