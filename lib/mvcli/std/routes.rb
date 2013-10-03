macro %r{^(-v|--version)} => "version"
match 'version' => proc { |cmd| cmd.output.puts ::MVCLI::Provisioning::Scope[:app].version }
