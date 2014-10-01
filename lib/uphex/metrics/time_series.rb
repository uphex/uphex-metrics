require 'uphex/metrics'
require 'uphex/metrics/time_series_entry'

module UpHex::Metrics
  class TimeSeries
    attr_reader :series

    def initialize(array_of_time_series_entries)
      @series = array_of_time_series_entries.
        map { |e| TimeSeriesEntry.to_time_series_entry e }.
        sort_by(&:date)
    end
  end
end
