require "spec_helper"

require "uphex/metrics/autoregressive_integrated_moving_average"
require "uphex/metrics/time_series"

describe UpHex::Metrics::AutoregressiveIntegratedMovingAverage do
  let(:time_series) { UpHex::Metrics::TimeSeries.new(data) }
  let(:arima)       { described_class.new(time_series)}

  describe "#forecast" do
    let(:data) { reps.times.map { |i| [Time.now + i, 73] } }

    context "with 19 observations" do
      let(:reps) { 19 }

      it { expect(arima.forecast[:forecast]).to be_between(72.9, 73.1) }
      it { expect(arima.forecast[:high]).to be < 73.1 }
      it { expect(arima.forecast[:low]).to be > 72.9 }
    end

    context "with 20 observations" do
      let(:reps) { 20 }

      it { expect(arima.forecast[:forecast]).to be_between(72.9, 73.1) }
      it { expect(arima.forecast[:high]).to be < 73.1 }
      it { expect(arima.forecast[:low]).to be > 72.9 }
    end
  end
end
