require "spec_helper"

require "uphex/metrics/exponential_moving_average"
require "uphex/metrics/time_series"

describe UpHex::Metrics::ExponentialMovingAverage do
  let(:time_series) { UpHex::Metrics::TimeSeries.new(source_data) }
  let(:ema)         { described_class.new(time_series)}
  let(:model)       { {period_count: 15, interval_ratio: 5} }
  let(:tolerance)   { 0.001 }

  describe "#forecast" do
    let(:forecast_periods) { 3 }
    let(:range)            { Range.new(0, 5 + rand(5)) }
    let(:results)          { ema.forecast(forecast_periods, range: range, model: model) }

    it { expect(results.size).to eq forecast_periods }

    context "comparing results with truth data" do
      let(:first_result) { results[0] }
      let(:truth_value)  { truth_data[range.end][0] }
      let(:diff)         { (first_result[:forecast] - truth_value).abs / truth_value }

      it { expect(diff).to be <= tolerance }
    end
  end

  describe "#forecast_comparison" do
    let(:range)              { 0..15 }
    let(:foreward)           { 5 }
    let(:expected_forecasts) { time_series.size - range.max - 1 + foreward }
    let(:results)            { ema.comparison_forecast(foreward, range: range, model: model) }

    it { expect(results.size).to eq expected_forecasts }

    describe "comparing results with truth data" do
      let(:offset) { range.max + 1 }

      it do
        results.each_with_index do |result, i|
          break if i + offset >= time_series.size

          t = truth_data[offset + i]
          diff = (result[:forecast] - t[0]).abs / t[0]
          expect(diff).to be <= tolerance

          diff = (result[:low] - t[1]).abs / t[1]
          expect(diff).to be <= tolerance

          diff = (result[:high] - t[2]).abs / t[2]
          expect(diff).to be <= tolerance
        end
      end
    end
  end

  def source_data
    [
      [Time.new(2010, 03,  1), 6602],
      [Time.new(2010, 03,  2), 7298],
      [Time.new(2010, 03,  3), 6885],
      [Time.new(2010, 03,  4), 7106],
      [Time.new(2010, 03,  5), 6475],
      [Time.new(2010, 03,  6), 4710],
      [Time.new(2010, 03,  7), 4573],
      [Time.new(2010, 03,  8), 6325],
      [Time.new(2010, 03,  9), 6199],
      [Time.new(2010, 03, 10), 6242],
      [Time.new(2010, 03, 11), 6805],
      [Time.new(2010, 03, 12), 6054],
      [Time.new(2010, 03, 13), 4677],
      [Time.new(2010, 03, 14), 5685],
      [Time.new(2010, 03, 15), 8287],
      [Time.new(2010, 03, 16), 7735],
      [Time.new(2010, 03, 17), 6736],
      [Time.new(2010, 03, 18), 7020],
      [Time.new(2010, 03, 19), 8196],
      [Time.new(2010, 03, 20), 8570],
      [Time.new(2010, 03, 21), 6361],
      [Time.new(2010, 03, 22), 8161],
      [Time.new(2010, 03, 23), 8068],
      [Time.new(2010, 03, 24), 6460],
      [Time.new(2010, 03, 25), 6446],
      [Time.new(2010, 03, 26), 5692],
      [Time.new(2010, 03, 27), 4454],
      [Time.new(2010, 03, 28), 4640],
      [Time.new(2010, 03, 29), 6443],
      [Time.new(2010, 03, 30), 6136],
      [Time.new(2010, 03, 31), 5843],
    ]
  end

  def truth_data
    [
      [6602,        6602,        6602       ],
      [6689,        3644,        9734       ],
      [6713.5,      4762.25,     8664.75    ],
      [6762.5625,   4889.333333, 8635.791667],
      [6726.617188, 5007.173828, 8446.060547],
      [6474.540039, 3334.445313, 9614.634766],
      [6236.847534, 2233.562317, 10240.13275],
      [6247.866592, 2761.383972, 9734.349213],
      [6241.758268, 3164.362058, 9319.154479],
      [6241.788485, 3506.207678, 8977.369291],
      [6312.189924, 3603.76216,  9020.617688],
      [6279.916184, 3715.019951, 8844.812416],
      [6079.551661, 3144.000256, 9015.103066],
      [6030.232703, 3187.711136, 8872.754271],
      [6312.328615, 2967.604522, 9657.052708],
      [6490.162538, 2953.474231, 10026.85085],
      [6520.892221, 3138.025752, 9903.75869 ],
      [6583.280693, 3270.959515, 9895.601872],
      [6784.870607, 3264.586884, 10305.15433],
      [7008.011781, 3261.956618, 10754.06694],
      [6927.135308, 3226.849076, 10627.42154],
      [7081.368395, 3300.231125, 10862.50566],
      [7204.697345, 3399.224803, 11010.16989],
      [7111.610177, 3329.938576, 10893.28178],
      [7028.408905, 3282.971765, 10773.84604],
      [6861.357792, 3031.86658,  10690.849  ],
      [6560.438068, 2473.150735, 10647.7254 ],
      [6320.383309, 2073.294895, 10567.47172],
      [6335.710396, 2221.144852, 10450.27594],
      [6310.746596, 2307.9339,   10313.55929],
      [6252.278272, 2314.67962,  10189.87692]
    ]
  end
end
