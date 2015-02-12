require "open3"

module UpHex
  module Metrics
    class AutoregressiveIntegratedMovingAverage
      def initialize(time_series)
        @time_series = time_series
      end

      def forecast
        path = File.expand_path("../../../../lib_python/autoregressive_integrated_moving_average.py", __FILE__)

        raise "Couldn't find Python script" unless File.exist?(path)

        stdin, stdout, stderr, _wait = Open3.popen3("python2 #{path}")

        stdin << @time_series.series.map(&:value).join(" ") + "\n"

        if (output = stdout.read.strip).empty?
          raise stderr.read
        else
          forecast, low, high = output.split.map(&:to_f)

          {time: @time_series.last.time.since(1.day), forecast: forecast, low: low, high: high}
        end
      end
    end
  end
end
