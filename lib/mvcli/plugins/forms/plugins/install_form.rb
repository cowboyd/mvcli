class MVCLI::Plugins::InstallForm < MVCLI::Form

  input :path, Pathname, decode: ->(s) { Pathname s }

  validates(:path, "no such directory") { |path| path.exist? }
end
