module Efile
  module Ny
    class It215 < ::Efile::TaxCalculator
      # https://www.tax.ny.gov/forms/current-forms/it/it215i.htm

      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = intake.direct_file_data
        @intake = intake

        @nyc_eic_rate_worksheet = Efile::Ny::NycEicRateWorksheet.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
        )
      end

      def calculate
        set_line(:IT215_LINE_1, @direct_file_data, :fed_eic_claimed)
        set_line(:IT215_LINE_2, -> { false }) # Confirmed this should always be false
        set_line(:IT215_LINE_3, :calculate_line_3)
        set_line(:IT215_LINE_4, @direct_file_data, :fed_eic_qc_claimed)
        set_line(:IT215_LINE_5, -> {false}) # Confirmed this should always be false
        # https://www.tax.ny.gov/forms/current-forms/it/it215i.htm#worksheet-a
        set_line(:IT215_WK_A_LINE_1, @direct_file_data, :fed_wages_salaries_tips) # clergy pay is not supported
        set_line(:IT215_WK_A_LINE_2, @direct_file_data, :fed_nontaxable_combat_pay_amount)
        set_line(:IT215_WK_A_LINE_3, :calculate_wk_a_line_3)
        set_line(:IT215_LINE_6, -> { @lines[:IT215_WK_A_LINE_3].value })
        # lines 7 & 8 are not supported
        set_line(:IT215_LINE_9, -> { @lines[:IT201_LINE_19].value })
        set_line(:IT215_LINE_10, @direct_file_data, :fed_eic)
        set_line(:IT215_LINE_11, -> { 0.3 }) # not used in pdf or xml. only used for calculating line 12
        set_line(:IT215_LINE_12, :calculate_line_12)
        set_line(:IT215_WK_B_LINE_1, -> { @lines[:IT201_LINE_39].value })
        set_line(:IT215_WK_B_LINE_2, -> { 0 }) # any other value not currently supported
        set_line(:IT215_WK_B_LINE_3, -> { 0 }) # any other value not currently supported
        set_line(:IT215_WK_B_LINE_4, :calculate_wk_b_line_4)
        set_line(:IT215_WK_B_LINE_5, :calculate_wk_b_line_5)
        set_line(:IT215_LINE_13, -> { @lines[:IT215_WK_B_LINE_5].value })
        set_line(:IT215_LINE_14, -> { @lines[:IT201_LINE_40].value })
        set_line(:IT215_LINE_15, :calculate_line_15)
        set_line(:IT215_LINE_16, :calculate_line_16)

        # lines 17-26 are out of scope

        # https://www.tax.ny.gov/forms/current-forms/it/it215i.htm#worksheet-c
        set_line(:IT215_WK_C_LINE_1, -> { @lines[:IT215_LINE_10].value })
        @nyc_eic_rate_worksheet.calculate
        set_line(:IT215_WK_C_LINE_2, -> { @lines[:NYC_EIC_RATE_WK_LINE_6].value })
        set_line(:IT215_WK_C_LINE_3, :calculate_wk_c_line_3)
        # worksheet c line 4 is out of scope

        set_line(:IT215_LINE_27, -> {@lines[:IT215_WK_C_LINE_3].value})
      end

      def calculate_line_3
        @lines[:IT215_LINE_1].value == true && @intake.filing_status == :married_filing_separately
      end

      def calculate_wk_a_line_3
        line_or_zero(:IT215_WK_A_LINE_1) + line_or_zero(:IT215_WK_A_LINE_2)
      end

      def calculate_line_12
        (line_or_zero(:IT215_LINE_10) * @lines[:IT215_LINE_11].value).round
      end

      def calculate_wk_b_line_4
        @lines[:IT215_WK_B_LINE_2].value + @lines[:IT215_WK_B_LINE_3].value
      end

      def calculate_wk_b_line_5
        [@lines[:IT215_WK_B_LINE_1].value - @lines[:IT215_WK_B_LINE_4].value, 0].max
      end

      def calculate_line_15
        [@lines[:IT215_LINE_13].value, @lines[:IT215_LINE_14].value].min
      end

      def calculate_line_16
        @lines[:IT215_LINE_12].value - @lines[:IT215_LINE_15].value
      end

      def calculate_wk_c_line_3
        (line_or_zero(:IT215_WK_C_LINE_1) * @lines[:IT215_WK_C_LINE_2].value).round
      end
    end
  end
end
