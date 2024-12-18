module Efile
  module Id
    class Id39RCalculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_data = intake.direct_file_data
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:ID39R_A_LINE_7, -> { 0 })
        set_line(:ID39R_B_LINE_3, :calculate_sec_b_line_3)
        set_line(:ID39R_B_LINE_7, :calculate_sec_b_line_7)
        set_line(:ID39R_B_LINE_6, :calculate_sec_b_line_6)
        set_line(:ID39R_B_LINE_8f, -> { 0 })
        set_line(:ID39R_B_LINE_18, :calculate_sec_b_line_18)
        set_line(:ID39R_B_LINE_24, :calculate_sec_b_line_24)
        set_line(:ID39R_D_LINE_4, -> { 0 })
        @lines.transform_values(&:value)
      end


      private

      def calculate_sec_b_line_3
        sum = 0
        @direct_file_json_data.interest_reports.each do |interest_report|
          sum += interest_report.interest_on_government_bonds
        end
        sum.round
      end

      def calculate_sec_b_line_6
        # Child and Dependent Care Worksheet:
        # 1. Enter the amount of qualified expenses you incurred and paid in 2024. Don’t include amounts paid by your employer or excluded from taxable income
        line_1 = @direct_file_data.total_qualifying_dependent_care_expenses_no_limit

        # 2. Enter $12,000 for one or more child or dependent cared for during the year
        line_2 = @direct_file_data.dependent_cared_for_count.positive? ? 12_000 : 0

        # 3. Enter excluded benefits from Part III of Form 2441
        line_3 = @direct_file_data.excluded_benefits_amount

        # 4. Subtract line 3 from line 2. If zero or less, stop. You can’t claim the deduction
        line_4 = (line_2 - line_3)
        return 0 if line_4 <= 0

        # 5. Enter your earned income
        line_5 = @direct_file_data.primary_earned_income_amount

        # 6. If married filing a joint return, enter your spouse’s earned income. All others enter the amount from line 5
        line_6 = @direct_file_data.spouse_earned_income_amount

        # 7. Enter the smallest of lines 1, 4, 5, or 6 here and on Form 39R, Part B, line 6 Attach federal 2441 with return
        [line_1, line_4, line_5, line_6].min
      end

      def calculate_sec_b_line_7
        @direct_file_data.fed_taxable_ssb&.round || 0
      end

      def calculate_sec_b_line_18
        @intake.has_health_insurance_premium_yes? ? @intake.health_insurance_paid_amount&.round : 0
      end

      def calculate_sec_b_line_24
        # Total subtractions. Add lines 1 through 4, 5e through 7, and 8f through 23.
        line_or_zero(:ID39R_B_LINE_3) + line_or_zero(:ID39R_B_LINE_6) + line_or_zero(:ID39R_B_LINE_7) + line_or_zero(:ID39R_B_LINE_8f) + line_or_zero(:ID39R_B_LINE_18)
      end
    end
  end
end
