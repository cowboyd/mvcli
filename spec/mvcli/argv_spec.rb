require "spec_helper"
require "mvcli/argv"
require "shellwords"

describe "ARGV" do
  use_natural_assertions
  Given(:input) {Shellwords.shellsplit "before --one 1 --two=two stuff in the middle --three -f --four --no-five -p 6 --mo money --mo problems --two-word val --two-word-p after"}
  Given(:argv) {MVCLI::Argv.new input, [:three, :f, :five, :two_word_p]}

  context " options" do
    Given(:options) {argv.options}
    Then {options[:one] == ['1']}
    Then {options[:two] == ['two']}
    Then {options[:three] == [true]}
    Then {options[:f] == [true]}
    Then {options[:four] == []}
    Then {options[:five] == [false]}
    Then {options[:p] == ['6']}
    Then {options[:mo] == ['money', 'problems']}
    Then {options[:two_word] == ['val']}
    Then {options[:two_word_p] == [true]}
  end
  context " aruments" do
    Given(:arguments) {argv.arguments}
    Then {arguments == %w(before stuff in the middle after)}
  end
end
