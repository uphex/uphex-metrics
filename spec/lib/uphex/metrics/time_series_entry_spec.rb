require 'spec_helper'
require 'uphex/metrics/time_series'

describe UpHex::Metrics::TimeSeriesEntry do
  describe ".to_time_series_entry" do
    it "converts from hashes" do
      t = Time.now
      v = 100
      raw_hash     = {:time => t, :value => v}
      raw_ts_entry = described_class.to_time_series_entry raw_hash

      expect(raw_ts_entry.time).to eq t
      expect(raw_ts_entry.value).to eq v
    end

    it "converts from arrays" do
      t = Time.now
      v = 100
      raw_array = [t, v]
      raw_ts_entry = described_class.to_time_series_entry raw_array

      expect(raw_ts_entry.time).to eq t
      expect(raw_ts_entry.value).to eq v
    end

    it "is idempotent wrt TimeSeriesEntries" do
      e = described_class.new(Time.now, 100)
      expect(described_class.to_time_series_entry e).to eq e
    end
  end

  describe "#initialize" do
    it "raises an error for objects that aren't UTC-izable" do
      expect { described_class.new("2020-01-01", 123) }.to raise_error ArgumentError
    end

    it "doesn't raise an error for times" do
      expect { described_class.new(Time.parse('2020-01-01'), 123) }.to_not raise_error
    end

    it "doesn't raise an error for objects that are UTC-izable" do
      o = double("time-ish", :utc => "utc time-ish")
      expect { described_class.new(o, 123) }.to_not raise_error
    end
  end

  describe "#==" do
    let(:time)   { Time.now }
    let(:value)  { 123 }
    let(:target) { described_class.new(time, value) }

    it "is not equal for objects of a derived class" do
      c = Class.new(described_class)
      expect(target == c.new(time, value)).to be false
    end

    it "is reflexive" do
      expect(target == target).to be true
    end

    it "is equal for instances with identical state" do
      expect(target == described_class.new(time, value)).to be true
    end
  end
end
