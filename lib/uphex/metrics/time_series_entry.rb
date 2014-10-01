require 'uphex/metrics'

module UpHex::Metrics
  class TimeSeriesEntry < Struct.new(:date, :value)
    def self.to_time_series_entry(o)
      case o
      when Hash then new(o[:date], o[:value])
      when Array then new(o[0], o[1])
      when self then o
      else raise ArgumentError.new("can't make #{self} from #{o.class}")
      end
    end
  end
end
