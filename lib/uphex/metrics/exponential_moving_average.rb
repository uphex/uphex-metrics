module UpHex
  module Metrics
    class ExponentialMovingAverage
      def initialize(time_series)
        @time_series = time_series

        raise ArgumentError.new("Invalid data set size") if @time_series.size < 2
      end

      def forecast(foreward, options = {})
        range              = options.fetch(:range, 0..@time_series.size)
        period_count       = options.fetch(:model, {}).fetch(:period_count, 365.0)
        interval_ratio     = options.fetch(:model, {}).fetch(:interval_ratio, 5.0)
        alpha              = 2 / (period_count + 1.0)
        subset             = @time_series[range]
        initial_prediction = Prediction.new(subset[0].time, subset[0].value)
        context            = Context.new(alpha, interval_ratio, initial_prediction)
        forecasts          = []

        # Perform EM on the existing data
        1.upto(subset.length - 1) do |index|
          current = perform_prediction(context, subset[index].time, subset[index].value)

          context.last_prediction = current
        end

        # Run `foreward` periods ahead
        1.upto(foreward) do |index|
          next_time = context.last_prediction.time.since(1.day)
          current   = perform_prediction(context, next_time, context.last_prediction.predicted_value)

          forecasts << current.dup
          context.last_prediction = current
        end

        # Return predictions as hashes
        forecasts.map {|p| {time: p.time, forecast: p.predicted_value, low: p.low_range, high: p.high_range} }
      end

      def comparison_forecast(foreward, options = {})
        range              = options.fetch(:range, 0..@time_series.size)
        period_count       = options.fetch(:model, {}).fetch(:period_count, 365.0)
        interval_ratio     = options.fetch(:model, {}).fetch(:interval_ratio, 5.0)
        alpha              = 2 / (period_count + 1.0)
        initial_prediction = Prediction.new(@time_series[range.begin].time, @time_series[range.begin].value)
        context            = Context.new(alpha, interval_ratio, initial_prediction)
        foreward_range     = Range.new(range.min + 1, range.max)
        remaining_range    = Range.new(foreward_range.max + 1, @time_series.size)
        forecasts          = []

        # Perform EMA on the specified range
        @time_series[foreward_range].each do |item|
          context.last_prediction = perform_prediction(context, item.time, item.value)
        end

        # Perform EMA on the remainging dataset, stepping `foreward` points at a time
        remaining_range.step(foreward).each do |base_index|
          0.upto(foreward-1).each do |inner_index|
            offset = base_index + inner_index

            break if offset >= @time_series.size

            item    = @time_series[offset]
            current = perform_prediction(context, item.time, item.value)

            forecasts << current.dup
            context.last_prediction = current
          end
        end

        # Perform EMA `foreward` periods ahead, using the predicted values as the actual values
        0.upto(foreward - 1).each do |index|
          next_time = context.last_prediction.time.since(1.days)
          current   = perform_prediction(context, next_time, context.last_prediction.predicted_value)

          forecasts << current.dup
          context.last_prediction = current
        end

        # Return predictions as hashes
        forecasts.map {|p| {time: p.time, forecast: p.predicted_value, low: p.low_range, high: p.high_range}}
      end

      private

      class Context
        attr_accessor :residuals, :last_prediction, :alpha, :interval_ratio

        def initialize(alpha, interval_ratio, initial_prediction)
          @residuals       = []
          @alpha           = alpha
          @last_prediction = initial_prediction
          @interval_ratio  = interval_ratio
        end

        def residual_mean
          @residuals.inject(0.0) {|sum, r| sum + r} / @residuals.size
        end
      end

      class Prediction
        attr_accessor :low_range, :high_range, :predicted_value, :actual_value, :time, :outlier

        def initialize(time, value)
          @time            = time
          @actual_value    = value
          @low_range       = value
          @high_range      = value
          @predicted_value = value
          @outlier         = false
        end

        def outlier?
          !(@low_range..@high_range).cover? @predicted_value
        end
      end

      def perform_prediction(context, time, value)
        Prediction.new(time, value).tap do |prediction|
          prediction.predicted_value = context.alpha * prediction.actual_value + (1.0-context.alpha) * context.last_prediction.predicted_value
          residual                   = (prediction.predicted_value - prediction.actual_value).abs

          # Despite recalculating the mean residual every time through the loop,
          # keeping a running_mean accumulates rounding errors very quickly
          context.residuals << residual

          mean_residual         = context.residual_mean
          prediction.low_range  = prediction.predicted_value - context.interval_ratio * mean_residual
          prediction.high_range = prediction.predicted_value + context.interval_ratio * mean_residual
        end
      end
    end
  end
end
