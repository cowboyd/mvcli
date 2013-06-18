require "spec_helper"
require "mvcli/decoding"

describe "Map enrichment" do
  use_natural_assertions
  Given(:source) {Map foo: 'bar', one: '1'}
  When(:enrichment) {MVCLI::Decoding::TextFormat::Enrich.new source}
  context "with no enrichments" do
    Then {enrichment.foo == 'bar'}
    And {enrichment.one == '1'}
  end
  context "when enriching a single paramater" do
    When {enrichment.one {|o| o.to_i}}
    Then {enrichment.one == 1}
  end
  context "when enriching many parameters simultaneously" do
    When do
      enrichment.
        one {|o| o.to_i}.
        one {|i| i * 10}.
        foo {|f| f.capitalize}.
        foo {|f| f * 3}
    end
    Then {enrichment.one == 10}
    And {enrichment.foo == 'BarBarBar'}
    And {enrichment.values_at(:foo, :one) == ['BarBarBar', 10]}
    context "support for the Map interface" do
      Given(:h) {enrichment}
      Then {h.keys == ["foo", "one"]}
      And {h.values == ['BarBarBar', 10]}
      And {h.values_at(:foo) == ['BarBarBar']}
      And {h.values_at(:one) == [10]}
    end
  end
end
