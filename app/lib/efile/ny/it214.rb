module Efile
  module Ny
    class It214 < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:)
        @value_access_tracker = value_access_tracker
        @lines = lines
      end

      def calculate
        set_line(:IT214_LINE_33, -> { 0 })
      end
    end
  end
end
