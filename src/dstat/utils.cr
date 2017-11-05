require "toml"

module DStat
  class Utils
    @@config = {} of String => TOML::Type

    def self.config
      if @@config.empty?
        raw_config = File.read("/usr/local/dstat/config.toml")
        @@config = TOML.parse(raw_config)
      else
        @@config
      end
    end
  end
end
