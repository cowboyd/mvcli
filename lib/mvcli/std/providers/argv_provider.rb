require "mvcli/argv"

class MVCLI::ArgvProvider
  requires :command

  def value
    MVCLI::Argv.new command.argv
  end
end
