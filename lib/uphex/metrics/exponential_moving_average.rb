module UpHex
  module Metrics
    class ExponentialMovingAverage
      def initialize(time_series)
        @time_series = time_series

        raise ArgumentError.new("Invalid data set size") if @time_series.size < 2
      end

      def forecast(foreward, opts = {})
        opts = merge_default_options(opts)

        foreward = foreward

        period_count = opts[:model][:period_count]
        range = opts[:range]
        interval_ratio = opts[:model][:interval_ratio]

        alpha = 2.0/(period_count+1.0)

        # subset based on the provided range. defaults to the full range of data
        # Ruby is copy-on-write so if we dont change anything inside subset[] then we aren't duplicating the
        # entire timeseries
        subset = @time_series[range]

        # initial prediction
        initial_prediction = Prediction.new(subset[0].time, subset[0].value)

        context = Context.new(alpha, interval_ratio, initial_prediction)

        # the actual forecasts
        forecasts = []

        # perform EMA for the existing data
        1.upto(subset.length-1) do |index|
          #  produce the next Prediction
          current = perform_prediction(context, subset[index].time ,subset[index].value)
          # replace the last_prediction with the current
          context.last_prediction = current
        end

        # run ahead foreward periods
        1.upto(foreward) do |index|
          next_time = context.last_prediction.time.since(1.day)
          current = perform_prediction(context, next_time, context.last_prediction.predicted_value)
          forecasts << current.dup
          context.last_prediction = current
        end

        # map the forecasts to the hashed form
        forecasts.map {|p| {:time => p.time, :forecast => p.predicted_value, :low => p.low_range, :high => p.high_range}}
      end

      def comparison_forecast(foreward, opts = {})
        opts = merge_default_options(opts)

        period_count = opts[:model][:period_count]
        range = opts[:range]
        interval_ratio = opts[:model][:interval_ratio]

        alpha = 2.0/(period_count+1.0)

        # initial prediction
        initial_prediction = Prediction.new(@time_series[range.begin].time, @time_series[range.begin].value)
        context = Context.new(alpha, interval_ratio, initial_prediction)

        # bump the range forward one as we've already used the first point in the initial prediction
        foreward_range = Range.new(range.min+1,range.max)

        # perform EMA on the specified range
        @time_series[foreward_range].each do |item|
          current = perform_prediction(context, item.time, item.value)
          context.last_prediction = current
        end

        remaining_range = Range.new(foreward_range.max+1, @time_series.size)
        forecasts = []
        # perform EMA on the remainging dataset, stepping ``foreward`` points at a time
        remaining_range.step(foreward).each do |base_index|
          0.upto(foreward-1).each do |inner_index|
            offset = base_index + inner_index

            break if offset >= @time_series.size

            item = @time_series[offset]

            current = perform_prediction(context, item.time, item.value)
            forecasts << current.dup
            context.last_prediction = current
          end
        end

        # perform EMA ahead ``foreward`` -number of periods, using the predicted values as the actual values
        0.upto(foreward-1).each do |index|
          next_time = context.last_prediction.time.since(1.days)
          current = perform_prediction(context, next_time, context.last_prediction.predicted_value)
          forecasts << current.dup
          context.last_prediction = current
        end

        forecasts.map {|p| {:time => p.time, :forecast => p.predicted_value, :low => p.low_range, :high => p.high_range}}
      end

      private

      class Context
        attr_accessor :residuals, :last_prediction, :alpha, :interval_ratio

        def initialize(alpha, interval_ratio, initial_prediction)
          @residuals = []
          @alpha = alpha
          @last_prediction = initial_prediction
          @interval_ratio = interval_ratio
        end

        def residual_mean
          @residuals.inject(0.0) {|sum, r| sum + r} / @residuals.size
        end
      end

      class Prediction
        attr_accessor :low_range, :high_range, :predicted_value, :actual_value, :time, :outlier

        def initialize(time, value)
          @time = time
          @actual_value = value
          @low_range = value
          @high_range = value
          @predicted_value = value
          @outlier = false
        end

        def outlier?
          !(@low_range..@high_range).cover? @predicted_value
        end
      end

      def merge_default_options(opts)
        model = {period_count: 365.0, interval_ratio: 5.0}.merge((opts[:model] || {}))

        {model: model, range: (0..@time_series.size)}.merge(opts)
      end

      def perform_prediction(context, time, value)
        # Create a new prediction container for the next time/value pair
        current_prediction = Prediction.new(time, value)

        current_prediction.predicted_value = context.alpha * current_prediction.actual_value + (1.0-context.alpha) * context.last_prediction.predicted_value
        residual = (current_prediction.predicted_value - current_prediction.actual_value).abs

        # i dislike recalculating the mean residual every time through the loop, but keeping a running_mean
        # accumulates rounding errors very quickly
        context.residuals << residual
        mean_residual = context.residual_mean

        # calculate the low and high range for outlier determination
        current_prediction.low_range = current_prediction.predicted_value - context.interval_ratio * mean_residual
        current_prediction.high_range = current_prediction.predicted_value + context.interval_ratio * mean_residual

        return current_prediction
      end
    end
  end
end
