module MVCLI
  class Middleware
    class ExceptionLogger
      class ValidationSummary < Enumerator
        def initialize(validation)
          super &method(:yield)
          @validation = validation
        end

        def yield(output)
          @validation.violations.each do |key, messages|
            output << [key, messages]
          end
          @validation.errors.each do |key, exceptions|
            output << [key, exceptions.map {|ex| "#{ex.class}: #{ex.message}"}]
          end
          @validation.each do |name, child|
            if child.length > 1
              child.each_with_index do |c, i|
                ValidationSummary.new(c).each do |key, messages|
                  output << ["#{name}[#{i}].#{key}", messages]
                end
              end
            elsif first = child.first
              ValidationSummary.new(first).each do |key, messages|
                output << ["#{name}.#{key}", messages]
              end
            end
          end
        end

        def write(stream)
          each do |key, messages|
            messages.each do |msg|
              stream.puts "#{key}: #{msg}"
            end
          end
        end
      end
    end
  end
end
