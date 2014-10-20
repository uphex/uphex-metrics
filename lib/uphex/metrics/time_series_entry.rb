require 'uphex/metrics'
require 'active_support'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'

module UpHex::Metrics
  class TimeSeriesEntry
    attr_reader :time
    attr_reader :value

    def self.to_time_series_entry(o)
      case o
      when Hash then new(o[:time], o[:value])
      when Array then new(o[0], o[1])
      when self then o
      else raise ArgumentError.new("can't make #{self} from #{o.class}")
      end
    end

    def initialize(time, value)
      raise ArgumentError.new "not a time" unless time.respond_to?(:utc)
      @time  = time.utc
      @value = value
    end

    def ==(o)
      o.class == self.class && o.state == self.state
    end

    def state
      [@time, @value]
    end
  end
end
