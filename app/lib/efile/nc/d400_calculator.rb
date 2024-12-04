module Efile
  module Nc
    class D400Calculator < ::Efile::TaxCalculator
      attr_reader :lines
      set_refund_owed_lines refund: :NCD400_LINE_25, owed: :NCD400_LINE_19

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
        set_line(:NCD400_LINE_6, @direct_file_data, :fed_agi)
        set_line(:NCD400_LINE_9, :calculate_line_9)
        set_line(:NCD400_LINE_10B, :calculate_line_10b)
        set_line(:NCD400_LINE_11, :calculate_line_11)
        set_line(:NCD400_LINE_12A, :calculate_line_12a)
        set_line(:NCD400_LINE_12B, :calculate_line_12b)
        set_line(:NCD400_LINE_14, :calculate_line_14)
        set_line(:NCD400_LINE_15, :calculate_line_15)
        set_line(:NCD400_LINE_17, :calculate_line_17)
        set_line(:NCD400_LINE_18, :calculate_line_18)
        set_line(:NCD400_LINE_19, :calculate_line_19)
        set_line(:NCD400_LINE_20A, :calculate_line_20a)
        set_line(:NCD400_LINE_20B, :calculate_line_20b)
        set_line(:NCD400_LINE_23, :calculate_line_23)
        set_line(:NCD400_LINE_25, :calculate_line_25)
        set_line(:NCD400_LINE_26A, :calculate_line_26a)
        set_line(:NCD400_LINE_27, :calculate_line_27)
        set_line(:NCD400_LINE_28, :calculate_line_28)
        set_line(:NCD400_LINE_34, :calculate_line_34)
        @lines.transform_values(&:value)
      end

      def calculate_use_tax(nc_taxable_income)
        return 0 if nc_taxable_income.nil?

        brackets = [
          [-Float::INFINITY, 2200, 1], [2200, 3700, 2], [3700, 5200, 3], [5200, 6700, 4],
          [6700, 8100, 5], [8100, 9600, 6], [9600, 11100, 7], [11100, 12600, 8],
          [12600, 14100, 9], [14100, 15600, 10], [15600, 17000, 11], [17000, 18500, 12],
          [18500, 20000, 13], [20000, 21500, 14], [21500, 23000, 15], [23000, 24400, 16],
          [24400, 25900, 17], [25900, 27400, 18], [27400, 28900, 19], [28900, 30400, 20],
          [30400, 31900, 21], [31900, 33300, 22], [33300, 34800, 23], [34800, 36300, 24],
          [36300, 37800, 25], [37800, 39300, 26], [39300, 40700, 27], [40700, 42200, 28],
          [42200, 43700, 29], [43700, 45200, 30]
        ]

        bracket = brackets.find { |min, max, _| nc_taxable_income >= min && nc_taxable_income < max }

        if bracket
          bracket[2]
        else
          (nc_taxable_income * 0.000675).round
        end
      end

      def analytics_attrs
        {}
      end

      def calculate_gov_payments
        sum = 0

        @intake.state_file1099_gs.each do |state_file_1099_g|
          if @intake.filing_status_mfj? || state_file_1099_g.recipient_primary?
            sum += state_file_1099_g.unemployment_compensation_amount&.round
          end
        end

        sum
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
        line_or_zero(:NCD400_S_LINE_41) + line_or_zero(:NCD400_LINE_10B) + line_or_zero(:NCD400_LINE_11)
      end

      def calculate_line_12b
        # Subtract Line 12a from Line 8 (which is just fed_agi)
        @direct_file_data.fed_agi - line_or_zero(:NCD400_LINE_12A)
      end

      def calculate_line_14
        line_or_zero(:NCD400_LINE_12B)
      end

      def calculate_line_15
        [(line_or_zero(:NCD400_LINE_14) * 0.045).round, 0].max
      end

      def calculate_line_17
        # Line 15 minus Line 16 (line 16 is 0/blank)
        line_or_zero(:NCD400_LINE_15)
      end

      def calculate_line_18
        # Consumer use tax
        if @intake.untaxed_out_of_state_purchases_yes?
          if @intake.sales_use_tax_calculation_method_manual?
            @intake.sales_use_tax.round.to_i
          else
            calculate_use_tax(line_or_zero(:NCD400_LINE_14))
          end
        else
          0
        end
      end

      def calculate_line_19
        # Add Lines 17 and 18
        line_or_zero(:NCD400_LINE_17) + line_or_zero(:NCD400_LINE_18)
      end

      def calculate_line_20a
        sum = 0

        @intake.state_file_w2s.each do |w2|
          if w2.employee_ssn == @intake.primary.ssn
            sum += w2.state_income_tax_amount&.round
          end
        end

        @intake.state_file1099_gs.each do |state_file_1099_g|
          if state_file_1099_g.recipient_primary?
            sum += state_file_1099_g.state_income_tax_withheld_amount&.round
          end
        end

        sum
      end

      def calculate_line_20b
        sum = 0

        @intake.state_file_w2s.each do |w2|
          if w2.employee_ssn == @intake.spouse.ssn
            sum += w2.state_income_tax_amount&.round
          end
        end

        @intake.state_file1099_gs.each do |state_file_1099_g|
          if state_file_1099_g.recipient_spouse?
            sum += state_file_1099_g.state_income_tax_withheld_amount&.round
          end
        end

        sum
      end

      def calculate_line_23
        # sum of lines 20a through 22
        # 21a, 21c, 21d, and 22 are all blank
        # 21b is blank unless DF decides to support
        line_or_zero(:NCD400_LINE_20A) + line_or_zero(:NCD400_LINE_20B)
      end

      def calculate_line_25
        # line 23 - line 24 (line 24 not in scope)
        line_or_zero(:NCD400_LINE_23)
      end

      def calculate_line_26a
        # Owe Money: if Line 25 is less than Line 19, subtract Line 25 from Line 19.
        if line_or_zero(:NCD400_LINE_25) < line_or_zero(:NCD400_LINE_19)
          line_or_zero(:NCD400_LINE_19) - line_or_zero(:NCD400_LINE_25)
        end
      end

      def calculate_line_27
        # Total amount due: Sum of Lines 26a, 26d, and 26e (line 26d & 26e out of scope)
        line_or_zero(:NCD400_LINE_26A)
      end

      def calculate_line_28
        # Refund/Overpayment: if Line 25 is more than Line 19, subtract Line 19 from Line 25.
        if line_or_zero(:NCD400_LINE_25) > line_or_zero(:NCD400_LINE_19)
          line_or_zero(:NCD400_LINE_25) - line_or_zero(:NCD400_LINE_19)
        end
      end

      def calculate_line_34
        # Total refund amount: line 28 - line 33 (line 33 not in scope)
        line_or_zero(:NCD400_LINE_28)
      end

    end
  end
end
