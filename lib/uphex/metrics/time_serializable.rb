module UpHex::Metrics
  module TimeSerializable
    include Enumerable
    extend Forwardable

    attr_reader :series

    def_delegators :@series,
      :each,
      :size,
      :last
  end
end
