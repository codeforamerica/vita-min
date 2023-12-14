module Efile
  module Ny
    class It215 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = intake.direct_file_data
        @intake = intake
      end

      def calculate
        set_line(:IT215_LINE_1, @direct_file_data, :fed_eic_claimed)
        set_line(:IT215_LINE_2, -> { false })
        set_line(:IT215_LINE_3, -> { false }) # TODO: validate this is true for everybody, it has to do with MFS status
        set_line(:IT215_LINE_4, @direct_file_data, :fed_eic_qc_claimed)
        set_line(:IT215_LINE_5, -> {false})
        set_line(:IT215_LINE_6, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:IT215_LINE_9, -> { @lines[:IT201_LINE_19].value })
        set_line(:IT215_LINE_10, @direct_file_data, :fed_eic)
        set_line(:IT215_LINE_11, -> { 0.3 })
        set_line(:IT215_LINE_12, :calculate_line_12)
        set_line(:IT215_WK_B_LINE_1, -> { @lines[:IT201_LINE_39].value })
        set_line(:IT215_WK_B_LINE_2, -> { 0 })
        set_line(:IT215_WK_B_LINE_3, -> { 0 })
        set_line(:IT215_WK_B_LINE_4, :calculate_wk_b_line_4)
        set_line(:IT215_WK_B_LINE_5, :calculate_wk_b_line_5)
        set_line(:IT215_LINE_13, -> { @lines[:IT215_WK_B_LINE_5].value })
        set_line(:IT215_LINE_14, -> { @lines[:IT201_LINE_40].value })
        set_line(:IT215_LINE_15, :calculate_line_15)
        set_line(:IT215_LINE_16, :calculate_line_16)
        if @intake.nyc_full_year_resident_yes?
          set_line(:IT215_WK_C_LINE_1, -> { @lines[:IT215_LINE_10].value })
          set_line(:IT215_WK_C_LINE_2, :calculate_wk_c_line_2)
          set_line(:IT215_WK_C_LINE_3, :calculate_wk_c_line_3)
          set_line(:IT215_WK_C_LINE_4, :calculate_wk_c_line_4)
          set_line(:IT215_LINE_27, -> {@lines[:IT215_WK_C_LINE_3].value})
        end
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

      def calculate_wk_c_line_2
        rates = [
          [-99999999999999, 5000, nil, nil, 0.30],
          [5000, 7500, 4999, 0.30, nil],
          [7500, 15000, nil, nil, 0.25],
          [15000, 17500, 14999, 0.25, nil],
          [17500, 20000, nil, nil, 0.20],
          [20000, 22500, 19999, 0.20, nil],
          [22500, 40000, nil, nil, 0.15],
          [40000, 42500, 39999, 0.15, nil],
          [42500, 99999999999999, nil, nil, 0.10]
        ]

        ln_3_hardval = 0.00002
        ny_agi = @lines[:IT201_LINE_33].value
        rates_line = rates.find { |line| ny_agi >= line[0] && ny_agi < line[1] }
        return rates_line[4] if rates_line[4].present?

        ln_2_val = rates_line[2]
        ln_3_val = ny_agi - ln_2_val
        ln_4_val = ((ln_3_val * ln_3_hardval) * 10000).round / 10000.0
        ln_5_val = rates_line[3]

        ((ln_5_val - ln_4_val) * 10000).round / 10000.0
      end

      def calculate_wk_c_line_3
        (line_or_zero(:IT215_WK_C_LINE_1) * @lines[:IT215_WK_C_LINE_2].value).round
      end

      def calculate_wk_c_line_4
        # TODO with intake on asking client how they would like to split line 3 credits
      end
    end
  end
end
