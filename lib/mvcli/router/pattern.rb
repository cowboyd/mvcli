require "map"

module MVCLI
  class Router
    class Pattern
      def initialize(pattern)
        @matchers = compile pattern
      end

      def match(input)
        Match.new(@matchers, input).compute
      end

      private

      def compile(pattern)
        pattern.strip.split(/\s+/).map {|segment| Matcher[segment]}
      end

      class Matcher

        def self.[](segment)
          case segment
          when /^:(\w+)/ then Variable.new($1)
          else
            Literal.new(segment)
          end
        end

        def initialize(name)
          @name = name
        end

        def bind(input)
          {}
        end

        class Variable < Matcher
          def matches?(input)
            true
          end

          def bind(input)
            {@name => input}
          end
        end

        class Literal < Matcher
          def matches?(input)
            input == @name
          end
        end
      end

      class Match
        attr_reader :bindings

        def initialize(unsatisfied, input, satisfied = [], consumed = [], bindings = Map.new)
          @unsatisfied = unsatisfied
          @satisfied = satisfied
          @input = input
          @consumed = consumed
          @bindings = bindings
        end

        def compute
          matcher = @unsatisfied.first
          input = @input.first
          if matcher && input && matcher.matches?(input)
            Match.new(@unsatisfied.slice(1..-1), @input.slice(1..-1), @satisfied + [matcher], @consumed + [input], @bindings.merge(matcher.bind(input))).compute
          else
            self
          end
        end

        def satisfied?
          @unsatisfied.empty?
        end

        def exhaustive?
          @input.empty?
        end

        def matches?
          satisfied? && exhaustive?
        end

        def partial?
          !@consumed.empty?
        end
      end
    end
  end
end
