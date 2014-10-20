require 'spec_helper'
require 'uphex/metrics/interval'

describe UpHex::Metrics::Interval do
  context "#initialize" do
    it {
      expect { described_class.new(nil, 1, 2) }.
         to raise_error ArgumentError
    }
    it {
      t = Time.new(2000, 1, 1)

      expect { described_class.new(t..t, 1, 2) }.
        to raise_error ArgumentError
    }
    it {
      t1 = Time.new(2000, 1, 1)
      t2 = Time.new(2000, 1, 2)

      expect(described_class.new(t1..t2, 1, 2)).
        to_not be nil
    }
  end
end
