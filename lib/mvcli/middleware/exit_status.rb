class MVCLI::Middleware
  EX_SOFTWARE = 70

  class ExitStatus
    def call(command)
      result = yield command
      result.is_a?(Integer) ? result : 0
    rescue Exception => e
      return EX_SOFTWARE
    end
  end
end
