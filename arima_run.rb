$: << "lib"

require "uphex/metrics/autoregressive_integrated_moving_average"
require "uphex/metrics/time_series"
require "uphex/metrics"

now = Time.now.utc
val = ARGV[0].to_f || 73
len = ARGV[1].to_i || 100
t_s = UpHex::Metrics::TimeSeries.new(len.times.map { |i| [now.advance(days: i - len), val] })

puts UpHex::Metrics::AutoregressiveIntegratedMovingAverage.new(t_s).forecast
