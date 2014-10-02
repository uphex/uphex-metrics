require 'spec_helper'
require 'uphex/metrics/time_series'

describe UpHex::Metrics::TimeSeriesEntry do
  describe ".to_time_series_entry" do
    it "converts from hashes" do
      t = Time.now
      v = 100
      raw_hash     = {:date => t, :value => v}
      raw_ts_entry = described_class.to_time_series_entry raw_hash

      expect(raw_ts_entry.date).to eq t
      expect(raw_ts_entry.value).to eq v
    end

    it "converts from arrays" do
      t = Time.now
      v = 100
      raw_array = [t, v]
      raw_ts_entry = described_class.to_time_series_entry raw_array

      expect(raw_ts_entry.date).to eq t
      expect(raw_ts_entry.value).to eq v
    end

    it "is idempotent wrt TimeSeriesEntries" do
      e = described_class.new(Time.now, 100)
      expect(described_class.to_time_series_entry e).to eq e
    end
  end
end
