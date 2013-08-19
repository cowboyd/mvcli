require "mvcli"
require "mvcli/app"
require "readline"

module MVCLI
  class Console < MVCLI::App
    include Readline

    # Signature based on cucumber/aruba standard 
    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

      # Interrupt handling
      stty_save = `stty -g`.chomp
      trap('INT') { system('stty', stty_save); exit }

      # Readline config
      Readline.completer_word_break_characters = ""
      comp = proc { |s|
        ssf = Readline.line_buffer[0, Readline.point]
        possibilities = commands.grep( /^#{Regexp.escape(ssf)}/ )
        suggestions = possibilities
        last_word_break = ssf.rindex(/\s+/) || -1
        suggestions = possibilities.map{|p| p[last_word_break+1, p.length]}
        suggestions
      }
      Readline.completion_append_character = " "
      Readline.completion_proc = comp
      
      super()
    end

    def commands
      self.class.commands or []
    end

    class << self
      attr_accessor :commands
    end

    def execute!
      while cmd = readline_with_hist_management
        result = call MVCLI::Command.new(cmd.split, nil, @stdout, @stderr, ENV.dup)
        @stdout.puts "-> #{result}"
      end
      @kernel.exit 0
    end

    def readline_with_hist_management
      line = Readline.readline('>> ', true)
      return nil if line.nil?
      if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
        Readline::HISTORY.pop
      end
      line
    end
  end
end