require 'time'
require 'forwardable'
require 'active_support'
require 'active_support/core_ext/time'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date'
require 'uphex/metrics'
require 'uphex/metrics/interval'

module UpHex::Metrics
  class Normalizer
    attr_reader :series
    attr_reader :boundary_strategy

    def initialize(array_of_time_series_entries)
      @series = array_of_time_series_entries
      @boundary_strategy = DayBoundaryStrategy.new
    end

    def to_intervals
      results = []

      # map points [a, b, c, d] ⇒ intervals [a..b, b..c, c..d]
      self.series.each_cons(2).map do |left, right|
        ranges = divided_ranges_for(left, right)

        results.push(*intervals_for_divided_ranges(ranges, left.value, right.value))
      end

      results
    end


    def intervals_for_divided_ranges(intervals, left_value, right_value)
      most_ranges, last_range = intervals[0..-2], intervals.last
      intervals = most_ranges.map do |range|
        Interval.new(range, left_value, left_value)
      end
      intervals.push Interval.new(last_range, left_value, right_value)

      intervals
    end

    # Chop up the interval implied by (e1.time)..(e2.time) into smaller ranges
    # if need be, as defined by the boundary strategy.
    def divided_ranges_for(e1, e2)
      # for each day in this range, add a range for the date boundary
      boundary_strategy.boundaries_for(e1.time, e2.time).each_cons(2).map do |b1, b2|
        b1..b2
      end
    end

    # add a start and end interval which start and end on the boundary
    def align_intervals(intervals)
      i1 = intervals.first
      i2 = intervals.last

      r1 = boundary_strategy.beginning_range_for i1.time_range.min
      r2 = boundary_strategy.ending_range_for    i2.time_range.max

      first = Interval.for(r1, i1.left_value, i1.left_value)
      last  = Interval.for(r2, i2.right_value, i2.right_value)

      [first, *intervals, last].compact
    end
  end

  # An interval construction strategy that chops ranges up at day boundaries.
  class DayBoundaryStrategy
    def boundaries_for(t1, t2)
      raise ArgumentError.new("#{t1} is after #{t2}") if t1 > t2

      d1 = t1.to_date + 1
      d2 = t2.to_date

      boundaries = []

      if d1 <= d2
        boundaries = (d1..d2).to_a.map { |d|
          Time.utc d.year, d.month, d.day
        }
      end

      [t1, *boundaries, t2]
    end

    def beginning_range_for(t1)
      t = t1.beginning_of_day
      t..t1
    end

    def ending_range_for(t2)
      t = t2.end_of_day
      t2..t
    end
  end
end
