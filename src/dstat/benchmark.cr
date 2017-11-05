module DStat
  class Benchmark
    private def get_disk
      io = IO::Memory.new
      Process.run("df", {"/", "--output=target,avail"}, output: io)
      io.close

      io.to_s.split.last.to_i
    end

    private def get_mem
      available = 0

      parsed = File.read_lines("/proc/meminfo").map do |line|
        Tuple(String, String).from(line.split(/\s+/).first(2))
      end

      parsed.each do |desc, val|
        if desc.includes?("MemAvailable")
          available = val.to_i
          break
        end
      end
      available
    end

    private def get_load
      raw = File.read("/proc/loadavg").split(" ")
      averages = raw.first(3).map { |x| x.to_f }
      averages.sum(0) / averages.size
    end
  end
end
