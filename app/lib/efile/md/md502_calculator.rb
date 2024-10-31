module Efile
  module Md
    class Md502Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @md502b = Efile::Md::Md502bCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end

      def calculate
        # Exemptions
        set_line(:MD502_LINE_A_PRIMARY, :calculate_line_a_primary)
        set_line(:MD502_LINE_A_SPOUSE, :calculate_line_a_spouse)
        set_line(:MD502_LINE_A_COUNT, :calculate_line_a_count)
        set_line(:MD502_LINE_A_AMOUNT, :calculate_line_a_amount)
        set_line(:MD502_LINE_B_PRIMARY_SENIOR, :calculate_line_b_primary_senior)
        set_line(:MD502_LINE_B_SPOUSE_SENIOR, :calculate_line_b_spouse_senior)
        set_line(:MD502_LINE_B_PRIMARY_BLIND, :calculate_line_b_primary_blind)
        set_line(:MD502_LINE_B_SPOUSE_BLIND, :calculate_line_b_spouse_blind)
        set_line(:MD502_LINE_B_COUNT, :calculate_line_b_count)
        set_line(:MD502_LINE_B_AMOUNT, :calculate_line_b_amount)
        @md502b.calculate
        set_line(:MD502_LINE_C_COUNT, :calculate_line_c_count)
        set_line(:MD502_LINE_C_AMOUNT, :calculate_line_c_amount)
        set_line(:MD502_LINE_D_COUNT_TOTAL, :calculate_line_d_count_total)
        set_line(:MD502_LINE_D_AMOUNT_TOTAL, :calculate_line_d_amount_total)

        # Income
        set_line(:MD502_LINE_1, @direct_file_data, :fed_agi)
        set_line(:MD502_LINE_1A, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1B, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1D, @direct_file_data, :fed_taxable_pensions)
        set_line(:MD502_LINE_1E, :calculate_line_1e)

        # Additions
        set_line(:MD502_LINE_7, :calculate_line_7) # STUBBED: PLEASE REPLACE, don't forget line_data.yml

        # Subtractions
        set_line(:MD502_LINE_15, :calculate_line_15) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_LINE_16, :calculate_line_16) # STUBBED: PLEASE REPLACE, don't forget line_data.yml

        # Deductions
        set_line(:MD502_DEDUCTION_METHOD, :calculate_deduction_method)
        set_line(:MD502_LINE_17, :calculate_line_17)
        set_line(:MD502_LINE_18, :calculate_line_18)
        set_line(:MD502_LINE_19, :calculate_line_19)
        set_line(:MD502_LINE_20, :calculate_line_20)

        set_line(:MD502CR_PART_B_LINE_2, @direct_file_data, :fed_credit_for_child_and_dependent_care_amount)
        set_line(:MD502CR_PART_B_LINE_3, :calculate_md502_cr_part_b_line_3)
        set_line(:MD502CR_PART_B_LINE_4, :calculate_md502_cr_part_b_line_4)
        set_line(:MD502CR_PART_M_LINE_1, :calculate_md502_cr_part_m_line_1)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {}
      end

      def gross_income_amount
        if @direct_file_data.claimed_as_dependent?
          (@direct_file_data.fed_agi + line_or_zero(:MD502_LINE_7)) - line_or_zero(:MD502_LINE_15)
        else
          (@direct_file_data.fed_agi - @direct_file_data.fed_taxable_ssb) + line_or_zero(:MD502_LINE_7)
        end
      end

      private

      def calculate_md502_cr_part_b_line_3
        table_from_pdf = <<~PDF_COPY
          $0 $30,001 0.3200 $0 $50,001
          $30,001 $32,001 0.3168 $50,001 $53,001
          $32,001 $34,001 0.3136 $53,001 $56,001
          $34,001 $36,001 0.3104 $56,001 $59,001
          $36,001 $38,001 0.3072 $59,001 $62,001
          $38,001 $40,001 0.3040 $62,001 $65,001
          $40,001 $42,001 0.3008 $65,001 $68,001
          $42,001 $44,001 0.2976 $68,001 $71,001
          $44,001 $46,001 0.2944 $71,001 $74,001
          $46,001 $48,001 0.2912 $74,001 $77,001
          $48,001 $50,001 0.2880 $77,001 $80,001
          $50,001 $52,001 0.2848 $80,001 $83,001
          $52,001 $54,001 0.2816 $83,001 $86,001
          $54,001 $56,001 0.2784 $86,001 $89,001
          $56,001 $58,001 0.2752 $89,001 $92,001
          $58,001 $60,001 0.2720 $92,001 $95,001
          $60,001 $62,001 0.2688 $95,001 $98,001
          $62,001 $64,001 0.2656 $98,001 $101,001
          $64,001 $66,001 0.2624 $101,001 $104,001
          $66,001 $68,001 0.2592 $104,001 $107,001
          $68,001 $70,001 0.2560 $107,001 $110,001
          $70,001 $72,001 0.2528 $110,001 $113,001
          $72,001 $74,001 0.2496 $113,001 $116,001
          $74,001 $76,001 0.2464 $116,001 $119,001
          $76,001 $78,001 0.2432 $119,001 $122,001
          $78,001 $80,001 0.2400 $122,001 $125,001
          $80,001 $82,001 0.2368 $125,001 $128,001
          $82,001 $84,001 0.2336 $128,001 $131,001
          $84,001 $86,001 0.2304 $131,001 $134,001
          $86,001 $88,001 0.2272 $134,001 $137,001
          $88,001 $90,001 0.2240 $137,001 $140,001
          $90,001 $92,001 0.2208 $140,001 $143,001
          $92,001 $94,001 0.2176 $143,001 $146,001
          $94,001 $96,001 0.2144 $146,001 $149,001
          $96,001 $98,001 0.2112 $149,001 $152,001
          $98,001 $100,001 0.2080 $152,001 $155,001
          $100,001 $102,001 0.2048 $155,001 $158,001
          $102,001 $103,651 0.2016 $158,001 $161,001
          0 0 0.1984 $161,001 $161,101
          $103,651 inf 0.0000 $161,101 inf
        PDF_COPY

        row = Struct.new(:non_mfj_floor, :non_mfj_ceiling, :decimal, :mfj_floor, :mfj_ceiling)

        agi_bands = table_from_pdf.lines.map do |line|
          agi_band = line.split(" ")
          agi_band = agi_band.map { |item| item.gsub(/[$,]/, "").to_d }
          row.new(*agi_band)
        end

        agi_bands[0].mfj_floor = -Float::INFINITY
        agi_bands[0].non_mfj_floor = -Float::INFINITY
        agi_bands[-1].mfj_ceiling = Float::INFINITY
        agi_bands[-1].non_mfj_ceiling = Float::INFINITY

        agi = line_or_zero(:MD502_LINE_1)
        agi_band = agi_bands.find do |row|
          if filing_status_mfj?
            row.mfj_floor <= agi && agi < row.mfj_ceiling
          else
            row.non_mfj_floor <= agi && agi < row.non_mfj_ceiling
          end
        end

        agi_band.decimal
      end

      def calculate_md502_cr_part_b_line_4
        (line_or_zero(:MD502CR_PART_B_LINE_2) * @lines[:MD502CR_PART_B_LINE_3]&.value).round(0)
      end

      # filing status /	filer >= 65 /	spouse >= 65 /	agi <= threshold /	credit amount
      # mfj/qss/hoh	T	T	T	1750
      # mfj/qss/hoh	T	T	F	0
      # mfj/qss/hoh	T	F	T	1000
      # mfj/qss/hoh	T	F	F	0
      # mfj/qss/hoh	F	T	T	1000
      # mfj/qss/hoh	F	T	F	0
      # mfj/qss/hoh	F	F	T	0
      # mfj/qss/hoh	F	F	F	0
      # single/mfs	T	X	T	1000
      # single/mfs	T	X	F	0
      # single/mfs	F	X	T	0
      # single/mfs	F	X	F	0
      def calculate_md502_cr_part_m_line_1
        agi = line_or_zero(:MD502_LINE_1)
        credit = 0
        if (filing_status_mfj? || filing_status_qw? || filing_status_hoh?) && agi <= 150_000
          if @intake.primary_senior? && @intake.spouse_senior?
            credit = 1750
          elsif @intake.primary_senior? ^ @intake.spouse_senior?
            credit = 1000
          end
        elsif (filing_status_single? || filing_status_mfs?) && agi <= 100_000
          if @intake.primary_senior?
            credit = 1000
          end
        end
        credit
      end

      def calculate_line_a_primary
        @direct_file_data.claimed_as_dependent? ? nil : "X"
      end

      def calculate_line_a_spouse
        filing_status_mfj? ? "X" : nil
      end

      def calculate_exemption_amount
        # Exemption amount
        income_ranges = if filing_status_single? || filing_status_mfs?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 1600],
                            [125_001..150_000, 800],
                            [150_001..Float::INFINITY, 0]
                          ]
                        elsif filing_status_hoh? || filing_status_mfj? || filing_status_qw?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 3200],
                            [125_001..150_000, 3200],
                            [150_001..175_000, 1600],
                            [175_001..200_000, 800],
                            [200_001..Float::INFINITY, 0]
                          ]
                        else
                          [[-Float::INFINITY..Float::INFINITY, 0]]
                        end

        income_range_index = income_ranges.find_index { |(range, _)| range.include?(@direct_file_data.fed_agi) }

        income_ranges[income_range_index][1]
      end

      def calculate_line_a_count
        [@lines[:MD502_LINE_A_PRIMARY]&.value, @lines[:MD502_LINE_A_SPOUSE]&.value,].count(&:itself)
      end

      def calculate_line_a_amount
        calculate_exemption_amount * line_or_zero(:MD502_LINE_A_COUNT)
      end

      def calculate_line_b_primary_senior
        @intake.primary_senior? ? "X" : nil
      end

      def calculate_line_b_spouse_senior
        return nil unless filing_status_mfj? || filing_status_qw?

        @intake.spouse_senior? ? "X" : nil
      end

      def calculate_line_b_primary_blind
        @direct_file_data.is_primary_blind? ? "X" : nil
      end

      def calculate_line_b_spouse_blind
        return nil unless filing_status_mfj? || filing_status_qw?

        @direct_file_data.is_spouse_blind? ? "X" : nil
      end

      def calculate_line_b_count
        [
          @lines[:MD502_LINE_B_PRIMARY_SENIOR]&.value,
          @lines[:MD502_LINE_B_SPOUSE_SENIOR]&.value,
          @lines[:MD502_LINE_B_PRIMARY_BLIND]&.value,
          @lines[:MD502_LINE_B_SPOUSE_BLIND]&.value
        ].count(&:itself)
      end

      def calculate_line_b_amount
        line_or_zero(:MD502_LINE_B_COUNT) * 1000
      end

      def calculate_line_c_count
        # dependent exemption count 
        @lines[:MD502B_LINE_3].value
      end

      def calculate_line_c_amount
        # dependent exemption amount
        calculate_exemption_amount * line_or_zero(:MD502_LINE_C_COUNT)
      end

      def calculate_line_d_count_total
        # Add line A, B and C counts
        line_or_zero(:MD502_LINE_A_COUNT) + line_or_zero(:MD502_LINE_B_COUNT) + line_or_zero(:MD502_LINE_C_COUNT)
      end

      def calculate_line_d_amount_total
        # Add line A, B and C amounts
        line_or_zero(:MD502_LINE_A_AMOUNT) + line_or_zero(:MD502_LINE_B_AMOUNT) + line_or_zero(:MD502_LINE_C_AMOUNT)
      end

      def calculate_line_1e
        total_interest = @direct_file_data.fed_taxable_income + @direct_file_data.fed_tax_exempt_interest
        total_interest > 11_600
      end

      def calculate_line_7; end

      def calculate_line_15; end

      def calculate_line_16; end

      FILING_MINIMUMS_NON_SENIOR = {
        single: 14_600,
        dependent: 14_600,
        married_filing_jointly: 29_200,
        married_filing_separately: 14_600,
        head_of_household: 21_900,
        qualifying_widow: 29_200
      }

      FILING_MINIMUMS_SENIOR = {
        single: 16_550,
        dependent: 16_550,
        married_filing_jointly: 30_750,
        married_filing_separately: 14_600,
        head_of_household: 23_850,
        qualifying_widow: 30_750
      }

      def calculate_deduction_method
        gross_income_amount = @intake.tax_calculator.gross_income_amount
        filing_minimum = if @intake.primary_senior? && @intake.spouse_senior? && @intake.filing_status_mfj?
                           32_300
                         elsif @intake.primary_senior?
                           FILING_MINIMUMS_SENIOR[@intake.filing_status]
                         else
                           FILING_MINIMUMS_NON_SENIOR[@intake.filing_status]
                         end
        if gross_income_amount >= filing_minimum
          "S"
        else
          "N"
        end
      end

      DEDUCTION_TABLES = {
        s_mfs_d: {
          12000 => 1_800,
          17999 => ->(x) { x * 0.15 },
          18000 => 2_700,
        },
        mfj_hoh_qss: {
          24333 => 3_650,
          36332 => ->(x) { x * 0.15 },
          36333 => 5_450,
        }
      }.freeze
      FILING_STATUS_GROUPS = {
        s_mfs_d: [:single, :married_filing_separately, :dependent],
        mfj_hoh_qss: [:married_filing_jointly, :head_of_household, :qualifying_widow]
      }.freeze

      def calculate_line_17
        if @lines[:MD502_DEDUCTION_METHOD]&.value == "S"
          status_group_key = FILING_STATUS_GROUPS.find { |_, group| group.include?(@intake.filing_status) }[0]
          deduction_table = DEDUCTION_TABLES[status_group_key]
          md_agi = line_or_zero(:MD502_LINE_16)
          amount_or_method = deduction_table.find { |agi_limit, _| md_agi <= agi_limit }[1]
          if amount_or_method.is_a?(Proc)
            amount_or_method.call(md_agi)
          else
            amount_or_method
          end
        else
          0
        end
      end

      def calculate_line_18
        if @lines[:MD502_DEDUCTION_METHOD]&.value == "S"
          line_or_zero(:MD502_LINE_16) - line_or_zero(:MD502_LINE_17)
        else
          0
        end
      end

      def calculate_line_19
        if @lines[:MD502_DEDUCTION_METHOD]&.value == "S"
          line_or_zero(:MD502_LINE_D_AMOUNT_TOTAL)
        else
          0
        end
      end

      def calculate_line_20
        if @lines[:MD502_DEDUCTION_METHOD]&.value == "S"
          [line_or_zero(:MD502_LINE_18) - line_or_zero(:MD502_LINE_19), 0].max
        else
          0
        end
      end

      def filing_status_dependent?
        @filing_status == :dependent
      end
    end
  end
end
