require "json"
require "net/http"
require "uri"

module UpHex
  module Metrics
    class AutoregressiveIntegratedMovingAverage
      def initialize(time_series)
        @time_series = time_series
      end

      def forecast
        series   = @time_series.series.map(&:value).join(" ") + "\n"
        response = request(series)
        data     = JSON.parse(response)

        {time: @time_series.last.time.advance(days: 1), forecast: data["forecast"], low: data["low"], high: data["high"]}
      rescue JSON::ParserError => e
        raise "Couldn't run prediction (#{response}) from series [#{series}]"
      end

      private

      def request(data)
        uri     = URI.parse(ENV.fetch("PREDICTION_SERVICE_URL", "http://localhost:5000"))
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)

        request.body = data
        request["Content-Type"] = "text/plain"

        http.request(request).body
      end
    end
  end
end
