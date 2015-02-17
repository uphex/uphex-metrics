module UpHex
  module Metrics
    class Interval
      attr_reader :time_range
      attr_reader :left_value
      attr_reader :right_value

      def self.for(time_range, left_value, right_value)
        return nil unless time_range
        return nil if time_range.min == time_range.max
        new time_range, left_value, right_value
      end

      def initialize(time_range, left_value, right_value)
        raise ArgumentError.new("range is nil") unless time_range
        raise ArgumentError.new("range is degenerate") if time_range.min == time_range.max
        @time_range  = time_range
        @left_value  = left_value
        @right_value = right_value
      end

      def ==(o)
        o.class == self.class && o.state == self.state
      end

      def state
        [@time_range, @left_value, @right_value]
      end
    end
  end
end
