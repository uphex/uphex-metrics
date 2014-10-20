require 'spec_helper'
require 'uphex/metrics/normalizer'
require 'uphex/metrics/time_series'

describe UpHex::Metrics::Normalizer do
  def entry_for(o)
    UpHex::Metrics::TimeSeriesEntry.to_time_series_entry o
  end

  describe "#to_intervals" do
    RSpec.shared_examples "an interval set" do
      subject {
        described_class.new(timeseries).to_intervals
      }

      it "first interval starts on first timeseries point" do
        first_interval_start         = subject.first.time_range.min
        first_timeseries_point_start = timeseries.first.time
        expect(first_interval_start).to eq first_timeseries_point_start
      end

      it "last interval ends on last timeseries point" do
        last_interval_end         = subject.last.time_range.max
        last_timeseries_point_end = timeseries.last.time
        expect(last_interval_end).to eq last_timeseries_point_end
      end

      it "generates the right number of intervals" do
        start_date = subject.first.time_range.begin.to_date
        end_date   = subject.last.time_range.end.to_date

        d = (end_date - start_date).to_i
        n = timeseries.size

        # there are (d + n) points, so there are (d + n - 1) intervals
        expect(subject.size).to eq (d + n - 1)
      end
    end

    context "with two points" do
      let(:timeseries) {
        UpHex::Metrics::TimeSeries.new(
          [
            entry_for([start_time, 60]),
            entry_for([end_time,   70]),
          ]
        )
      }

      let(:start_time)  { Time.utc(2014, 6,  1, 22, 0, 0) }

      context "separated by more than one date boundary" do
        let(:end_time)  { Time.utc(2014, 6, 10,  2, 0, 0) }
        it_behaves_like "an interval set"
      end

      context "separated by one date boundary" do
        let(:end_time)  { Time.utc(2014, 6,  2,  2, 0, 0) }
        it_behaves_like "an interval set"
      end

      context "separated by zero date boundaries" do
        let(:end_time)  { Time.utc(2014, 6,  1, 23, 0, 0) }
        it_behaves_like "an interval set"
      end
    end
  end
end
