require "map"

module MVCLI
  class Router
    class Pattern
      def initialize(pattern)
        @matchers = compile pattern
      end

      def match(input, consumed = [], unsatisfied = @matchers, satisfied = [], bindings = Map.new)
        matcher = unsatisfied.first
        value = input.first
        unless matcher && value && matcher.matches?(value)
          Match.new input, consumed, unsatisfied, satisfied, bindings
        else
          match input.slice(1..-1), consumed + [value], unsatisfied.slice(1..-1), satisfied + [matcher], bindings.merge(matcher.bind(value))
        end
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

        def initialize(input, consumed, unsatisfied, satisfied, bindings)
          @unsatisfied = unsatisfied
          @satisfied = satisfied
          @input = input
          @consumed = consumed
          @bindings = bindings
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
