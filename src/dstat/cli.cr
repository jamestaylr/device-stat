module DStat
  class Cli
    def run
      OptionParser.parse! do |parser|
        parser.banner = "Usage: dstat [arguments]"

        parser.on("-r", "Check machine") {
          DStat::Benchmark.new.run
        }
        parser.on("-d", "Check machine") {
          DStat::Daemon.new.run
        }

        parser.invalid_option do |option|
          puts "No option found for #{option}"
          puts parser
          exit 1
        end
        parser.missing_option do |option|
          puts "No param found for #{option} option"
          puts parser
          exit 1
        end
      end
    end
  end
end
