require 'time'
require 'forwardable'
require 'uphex/metrics'
require 'uphex/metrics/time_series_entry'

module UpHex::Metrics
  class TimeSeries
    include Enumerable
    extend Forwardable

    attr_reader :series

    def_delegators :@series,
      :each,
      :size

    def initialize(array_of_time_series_entries)
      @series = array_of_time_series_entries.
        map { |e| TimeSeriesEntry.to_time_series_entry e }.
        sort_by(&:date).
        uniq(&:date)
    end

    def by_date
      @series.group_by { |e| e.date.to_date }.values
    end
  end
end
