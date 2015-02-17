require "spec_helper"

require "uphex/metrics/autoregressive_integrated_moving_average"
require "uphex/metrics/time_series"

describe UpHex::Metrics::AutoregressiveIntegratedMovingAverage do
  describe "#forecast" do
    it "predicts the next value" do
      series = UpHex::Metrics::TimeSeries.new([
        [Time.new(2010, 03,  1), 10],
        [Time.new(2010, 03,  2), 20],
        [Time.new(2010, 03,  3), 30],
        [Time.new(2010, 03,  4), 10],
        [Time.new(2010, 03,  5), 20],
      ])
      result = described_class.new(series).forecast

      expect(result[:forecast]).to be_between(29, 31)
      expect(result[:low]     ).to be_between(29, 30)
      expect(result[:high]    ).to be_between(30, 31)
    end
  end
end
