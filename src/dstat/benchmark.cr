module DStat
  class Benchmark
    private def get_disk
      io = IO::Memory.new
      Process.run("df", {"/", "--output=target,avail,size"}, output: io)
      io.close

      Tuple(Int32, Int32).from(io.to_s.split.last(2).map { |x| x.to_i })
    end

    private def get_mem
      total = 0
      available = 0

      parsed = File.read_lines("/proc/meminfo").map do |line|
        Tuple(String, String).from(line.split(/\s+/).first(2))
      end

      parsed.each do |desc, val|
        if desc.includes?("MemTotal")
          total = val.to_i
        elsif desc.includes?("MemAvailable")
          available = val.to_i
        end
      end
      {available, total}
    end

    private def get_load
      raw = File.read("/proc/loadavg").split(" ")
      averages = raw.first(3).map { |x| x.to_f }
      {averages.sum(0) / averages.size, System.cpu_count}
    end
  end
end
