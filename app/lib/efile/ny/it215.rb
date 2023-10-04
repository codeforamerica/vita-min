module Efile
  module Ny
    class It215 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:)
        @value_access_tracker = value_access_tracker
        @lines = lines
      end

      def calculate
        set_line(:IT215_LINE_16, -> { 0 })
      end
    end
  end
end
