module Efile
  module Ny
    class It215 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, direct_file_data:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = direct_file_data
      end

      def calculate
        set_line(:IT215_LINE_1, @direct_file_data, :fed_eic_claimed)
        set_line(:IT215_LINE_1A, -> {false})
        set_line(:IT215_LINE_2, -> {false})
        set_line(:IT215_LINE_3, -> {0}) #TODO
        set_line(:IT215_LINE_1, @direct_file_data, :fed_eic_claimed)
        set_line(:IT215_LINE_16, -> { 0 })
      end
    end
  end
end
