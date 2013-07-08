module MVCLI
  class Middleware
    class ExceptionLogger
      class ValidationSummary
        def initialize(validation)
          @validation = validation
        end

        def keys
          @validation.violations.keys
        end

        def values
          @validation.violations.values
        end

        def write
          #Write object to a stream
        end
      end
    end
  end
end
