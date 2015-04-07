require "spec_helper"

require "uphex/metrics/autoregressive_integrated_moving_average"
require "uphex/metrics/time_series"

describe UpHex::Metrics::AutoregressiveIntegratedMovingAverage do
  let(:time_series) { UpHex::Metrics::TimeSeries.new(data) }
  let(:arima)       { described_class.new(time_series)}

  describe "#forecast" do
    let(:data) { 4.times.map { |i| [Time.now - 4 + i, (i+1) * 10] } }

    before do
      expect(arima)
        .to receive(:request).with("10 20 30 40\n")
        .and_return(%|{"high": 50.00000001959944, "low": 49.99999998040056, "forecast": 50.0}|)
    end

    it { expect(arima.forecast[:forecast]).to eq 50.0 }
    it { expect(arima.forecast[:high]).to eq 50.00000001959944 }
    it { expect(arima.forecast[:low]).to eq 49.99999998040056 }
  end
end
