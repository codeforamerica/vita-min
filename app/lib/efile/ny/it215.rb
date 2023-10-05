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
        set_line(:IT_215_WK_B_LINE_1, -> { @lines[:AMT_39].value })
        set_line(:IT_215_WK_B_LINE_2, -> { 0 })
        set_line(:IT_215_WK_B_LINE_3, -> { 0 })
        set_line(:IT_215_WK_B_LINE_4, :calculate_wk_b_line_4)
        set_line(:IT_215_WK_B_LINE_5, :calculate_wk_b_line_5)
        set_line(:IT215_LINE_16, -> { 0 })
      end

      def calculate_line_12
        (@lines[:IT215_LINE_10].value * @lines[:IT215_LINE_11].value).round
      end

      def calculate_wk_b_line_4
        @lines[:IT_215_WK_B_LINE_2].value + @lines[:IT_215_WK_B_LINE_3].value
      end

      def calculate_wk_b_line_5
        [@lines[:IT_215_WK_B_LINE_1].value - @lines[:IT_215_WK_B_LINE_4].value, 0].min
      end
    end
  end
end
