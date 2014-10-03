require 'time'
require 'uphex/metrics'
require 'uphex/metrics/time_series_entry'

module UpHex::Metrics
  class TimeSeries
    include Enumerable

    attr_reader :series

    def initialize(array_of_time_series_entries)
      @series = array_of_time_series_entries.
        map { |e| TimeSeriesEntry.to_time_series_entry e }.
        sort_by(&:date).
        uniq(&:date)
    end

    def each(*args, &block)
      @series.each(*args, &block)
    end
  end
end
