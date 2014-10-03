require 'spec_helper'
require 'uphex/metrics/time_series'

describe UpHex::Metrics::TimeSeries do
  describe "#initialize" do
    it "generates a series sorted by ascending date" do
      t = Time.now
      first  = [t - 1, 1]
      second = [t - 2, 2]
      series = described_class.new([first, second]).series
      expect(series).to match [
        UpHex::Metrics::TimeSeriesEntry.to_time_series_entry(second),
        UpHex::Metrics::TimeSeriesEntry.to_time_series_entry(first),
      ]
    end
  end

  describe "#by_date" do
    def date_for(day_offset, minute_offset)
      Time.new 2014, 1, 15 + day_offset, 7, minute_offset, 9
    end

    def entry_for(o)
      UpHex::Metrics::TimeSeriesEntry.to_time_series_entry o
    end

    it "partitions the series into ordered date chunks" do
      first = [
        entry_for([date_for(1, 1), 60]),
        entry_for([date_for(1, 2), 70]),
        entry_for([date_for(1, 3), 80]),
      ]

      second = [
        entry_for([date_for(2, 1), 71]),
        entry_for([date_for(2, 2), 81]),
      ]

      third = [
        entry_for([date_for(3, 1), 82]),
      ]

      disordered_series = [*second, *third, *first]
      ordered_partitioned_series = [[*first], [*second], [*third]]

      expect(described_class.new(disordered_series).by_date).to \
        eq ordered_partitioned_series
    end
  end
end
