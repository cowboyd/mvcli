class MVCLI::Middleware
  class ExitStatus
    # <b>:ok,</b> <b>:success</b> - Successful termination
    EX_OK          = 0

    # <b>:_base</b> - The base value for sysexit codes
    EX__BASE       = 64

    # <b>:usage</b> - The command was used incorrectly, e.g., with the wrong
    # number of arguments, a bad flag, a bad syntax in a parameter, or whatever.
    EX_USAGE       = 64

    # <b>:dataerr,</b> <b>:data_error</b> - The input data was incorrect in
    # some way. This should only be used for user data, not system files.
    EX_DATAERR     = 65

    # <b>:noinput,</b> <b>:input_missing</b> - An input file (not a system
    # file) did not exist or was not readable. This could also include errors
    # like "No message" to a mailer (if it cared to catch it).
    EX_NOINPUT     = 66

    # <b>:nouser,</b> <b>:no_such_user</b> - The user specified did not exist.
    # This might be used for mail addresses or remote logins.
    EX_NOUSER      = 67

    # <b>:nohost,</b> <b>:no_such_host</b> - The host specified did not exist.
    # This is used in mail addresses or network requests.
    EX_NOHOST      = 68

    # <b>:unavailable,</b> <b>:service_unavailable</b> - A service is
    # unavailable.  This can occur if a support program or file does not exist.
    # This can also be used as a catchall message when something you wanted to
    # do doesn't work, but you don't know why.
    EX_UNAVAILABLE = 69

    # <b>:software,</b> <b>:software_error</b> - An internal software error has
    # been detected. This should be limited to non-operating system related
    # errors.
    EX_SOFTWARE    = 70

    # <b>:oserr,</b> <b>:operating_system_error</b> - An operating system error
    # has been detected.  This is intended to be used for such things as
    # "cannot fork", "cannot create pipe", or the like.  It includes things
    # like getuid returning a user that does not exist in the passwd file.
    EX_OSERR       = 71

    # <b>:osfile,</b> <b>:operating_system_file_error</b> - Some system file
    # (e.g., /etc/passwd, /etc/utmp, etc.) does not exist, cannot be opened, or
    # has some sort of error (e.g., syntax error).
    EX_OSFILE      = 72

    # <b>:cantcreat,</b> <b>:cant_create_output</b> - A (user specified) output
    # file cannot be created.
    EX_CANTCREAT   = 73

    # <b>:ioerr</b> - An error occurred while doing I/O on a file.
    EX_IOERR       = 74

    # <b>:tempfail,</b> <b>:temporary_failure,</b> <b>:try_again</b> - Temporary
    # failure, indicating something that is not really a serious error.  In
    # sendmail, this means that a mailer (e.g.) could not create a connection,
    # and the request should be reattempted later.
    EX_TEMPFAIL    = 75

    # <b>:protocol,</b> <b>:protocol_error</b> - The remote system returned
    # something that was "not possible" during a protocol exchange.
    EX_PROTOCOL    = 76

    # <b>:noperm,</b> <b>:permission_denied</b> - You did not have sufficient
    # permission to perform the operation. This is not intended for file
    # system problems, which should use NOINPUT or CANTCREAT, but rather
    # for higher level permissions.
    EX_NOPERM      = 77

    # <b>:config,</b> <b>:config_error</b> - There was an error in a
    # user-specified configuration value.
    EX_CONFIG      = 78

    def call(command)
      result = yield command
      result.is_a?(Integer) ? result : EX_OK
    rescue MVCLI::Validatable::ValidationError
      return EX_DATAERR
    rescue Exception => e
      return EX_SOFTWARE
    end
  end
end
