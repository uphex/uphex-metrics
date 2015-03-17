$: << "lib"

require "uphex/metrics/autoregressive_integrated_moving_average"
require "uphex/metrics/time_series"

now = Time.now.utc
val = Float(ARGV[0] || 73.0)
len = Integer(ARGV[1] || 100)
t_s = UpHex::Metrics::TimeSeries.new(len.times.map { |i| [now.advance(days: i - len), val] })

puts UpHex::Metrics::AutoregressiveIntegratedMovingAverage.new(t_s).forecast
