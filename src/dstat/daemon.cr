require "json"
require "http/server"

module DStat
  class Daemon
    def self.database : DB::Database
      config = Utils.config["database"].as(Hash)
      connection = [
        "postgres://#{config["user"]}:#{config["password"]}",
        "@localhost/stats",
      ].join

      DB.open connection
    end

    private def query_host(hostname)
      result = {} of String => Float64
      target = Time.now - 1.hours
      config = Utils.config["database"].as(Hash)

      connection = [
        "postgres://#{config["user"]}:#{config["password"]}",
        "@localhost/stats",
      ].join

      [
        "cpu",
        "memory",
        "disk",
      ].each do |type|
        query = [
          "SELECT avg(value) FROM metrics",
          "WHERE datetime > '#{target}' AND type='#{type}'",
          "AND hostname='#{hostname}'",
        ].join(" ")

        average = DStat::Daemon.database.query_one(query, as: PG::Numeric).to_f
        result[type] = average.round(2)
      end
      result
    end

    def query_all
      result = {} of String => Hash(String, Float64)
      ["capstone0", "capstone1", "capstone2"].each do |h|
        result[h] = query_host(h)
      end
      result
    end

    def run
      config = Utils.config["daemon"].as(Hash)
      port = config["port"].as(Int64).to_i32
      server = HTTP::Server.new(port) do |context|
        context.response.content_type = "text/plain"
        context.response.print query_all.to_json
      end
      server.listen
    end
  end
end
