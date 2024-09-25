module Efile
  module Nc
    class D400Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @d400_schedule_s = Efile::Nc::D400ScheduleSCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end


      def calculate
        @d400_schedule_s.calculate
        set_line(:NCD400_LINE_9, :calculate_line_9)
        set_line(:NCD400_LINE_10B, :calculate_line_10b)
        set_line(:NCD400_LINE_11, :calculate_line_11)
        set_line(:NCD400_LINE_12A, :calculate_line_12a)
        set_line(:NCD400_LINE_12B, :calculate_line_12b)
        set_line(:NCD400_LINE_15, :calculate_line_15)
>>>>>>> main
        set_line(:NCD400_LINE_20A, :calculate_line_20a)
        set_line(:NCD400_LINE_20B, :calculate_line_20b)
        set_line(:NCD400_LINE_23, :calculate_line_23)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0 # placeholder
      end

      private

      def calculate_line_9
        line_or_zero(:NCD400_S_LINE_41)
      end

      def calculate_line_10b
        income_ranges = if filing_status_single? || filing_status_mfs?
                          [0..20_000, 20_001..30_000, 30_001..40_000, 40_001..50_000, 50_001..60_000, 60_001..70_000, 70_001..Float::INFINITY]
                        elsif filing_status_hoh?
                          [0..30_000, 30_001..45_000, 45_001..60_000, 60_001..75_000, 75_001..90_000, 90_001..105_000, 105_001..Float::INFINITY]
                        elsif filing_status_mfj? || filing_status_qw?
                          [0..40_000, 40_001..60_000, 60_001..80_000, 80_001..100_000, 100_001..120_000, 120_001..140_000, 140_001..Float::INFINITY]
                        end
        income_range_index = income_ranges.find_index { |range| range.include?(@direct_file_data.fed_agi) }

        deduction_amounts = [3000, 2500, 2000, 1500, 1000, 500, 0]
        amount_per_child = deduction_amounts[income_range_index]

        amount_per_child * @direct_file_data.qualifying_children_under_age_ssn_count.to_i
      end

      STANDARD_DEDUCTIONS = {
        head_of_household: 19125,
        married_filing_jointly: 25500,
        married_filing_separately: 12750,
        qualifying_widow: 25500,
        single: 12750,
      }.freeze
      def calculate_line_11
        STANDARD_DEDUCTIONS[@intake.filing_status]
      end

      def calculate_line_12a
        # Add Lines 9, 10b, and 11
        # line 9 DeductionsFromFAGI is blank
        line_or_zero(:NCD400_LINE_10B) + line_or_zero(:NCD400_LINE_11)
      end

      def calculate_line_12b
        # Subtract Line 12a from Line 8
        # line 8 is just fed agi
        @direct_file_data.fed_agi - line_or_zero(:NCD400_LINE_12A)
      end

      def calculate_line_15
        [(line_or_zero(:NCD400_LINE_12B) * 0.045).round, 0].max
      end

      def calculate_line_20a
        @direct_file_data.w2s.reduce(0) do |sum, w2|
          if w2.EmployeeSSN == @direct_file_data.primary_ssn
            sum += w2.StateIncomeTaxAmt
          end
          sum
        end
      end

      def calculate_line_20b
        @direct_file_data.w2s.reduce(0) do |sum, w2|
          if w2.EmployeeSSN == @direct_file_data.spouse_ssn
            sum += w2.StateIncomeTaxAmt
          end
          sum
        end
      end

      def calculate_line_23
        # sum of lines 20a through 22
        # 21a, 21c, 21d, and 22 are all blank
        # 21b is blank unless DF decides to support
        line_or_zero(:NCD400_LINE_20A) + line_or_zero(:NCD400_LINE_20B)
      end
    end
  end
end
