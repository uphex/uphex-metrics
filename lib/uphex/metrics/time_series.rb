require 'time'
require 'forwardable'
require 'active_support'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date'
require 'uphex/metrics'
require 'uphex/metrics/time_series_entry'
require 'uphex/metrics/time_serializable'

module UpHex::Metrics
  class TimeSeries
    include TimeSerializable

    def initialize(array_of_time_series_entries)
      @series = array_of_time_series_entries.
        map { |e| TimeSeriesEntry.to_time_series_entry e }.
        sort_by(&:time).
        uniq(&:time)
    end

    def by_date
      @series.group_by { |e| e.time.to_date }.values
    end
  end
end
