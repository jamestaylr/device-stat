require "json"
require "http/server"

module DStat
  class Daemon
    private def query_self
      result = {} of String => Float64
      target = Time.now - 1.hours
      config = Utils.config["database"].as(Hash)

      connection = [
        "postgres://#{config["user"]}:#{config["password"]}",
        "@localhost/stats",
      ].join

      DB.open connection do |db|
        [
          "cpu",
          "memory",
          "disk",
        ].each do |type|
          query = [
            "SELECT avg(value) FROM metrics",
            "WHERE datetime > '#{target}' AND type='#{type}'",
          ].join(" ")

          average = db.query_one(query, as: PG::Numeric).to_f
          result[type] = average.round(2)
        end
      end
      result
    end

    def run
      config = Utils.config["daemon"].as(Hash)
      port = config["port"].as(Int64).to_i32
      server = HTTP::Server.new(port) do |context|
        context.response.content_type = "text/plain"
        context.response.print query_self.to_json
      end
      server.listen
    end
  end
end
