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
end
