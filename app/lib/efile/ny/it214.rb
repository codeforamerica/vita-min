module Efile
  module Ny
    class It214 < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, direct_file_data:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = direct_file_data
        @intake = intake
      end

      def calculate
        set_line(:IT214_LINE_9, @direct_file_data, :fed_agi)
        set_line(:IT214_LINE_33, -> { 0 })
      end
    end
  end
end
