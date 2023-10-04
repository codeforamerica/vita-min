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
        set_line(:IT215_LINE_3, -> { 0 }) # TODO: line 3 is replaced in 2023 form, update it when we get that
        set_line(:IT215_LINE_4, @direct_file_data, :fed_eic_qc_claimed)
        set_line(:IT215_LINE_5, -> {false})
        set_line(:IT215_LINE_6, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:IT215_LINE_9, -> { @lines[:AMT_19].value })
        set_line(:IT215_LINE_10, @direct_file_data, :fed_eic)
        set_line(:IT215_LINE_11, -> { 0.3 })
        set_line(:IT215_LINE_12, :calculate_line_12)
        set_line(:IT215_LINE_16, -> { 0 })
      end

      def calculate_line_12
        (@lines[:IT215_LINE_10].value * @lines[:IT215_LINE_11].value).round
      end
    end
  end
end
