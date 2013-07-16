require "map"

module MVCLI
  class Router
    class Pattern
      def initialize(pattern)
        @matchers = compile pattern
      end

      def match(input, consumed = [], matchers = @matchers, satisfied = [], bindings = Map.new)
        matcher, *unsatisfied = *matchers
        value, *rest = *input
        unless matcher && value && matcher.matches?(value)
          Match.new input, consumed, matchers, satisfied, bindings
        else
          match rest, consumed + [value], unsatisfied, satisfied + [matcher], bindings.merge(matcher.bind(value))
        end
      end

      def to_s
        @matchers.map{ |m| m.to_s }.join(" ")
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

          def to_s
            ":#{@name}"
          end
        end

        class Literal < Matcher
          def matches?(input)
            input == @name
          end

          def to_s
            @name
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
