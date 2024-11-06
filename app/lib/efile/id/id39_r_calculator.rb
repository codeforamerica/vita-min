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
        set_line(:ID39R_B_LINE_8a, -> { 0 })
        set_line(:ID39R_B_LINE_8b, -> { 0 })
        set_line(:ID39R_B_LINE_8c, -> { 0 })
        set_line(:ID39R_B_LINE_8e, -> { 0 })
        set_line(:ID39R_B_LINE_8f, -> { 0 })
        set_line(:ID39R_B_LINE_18, :calculate_sec_b_line_18)
        set_line(:ID39R_B_LINE_24, :calculate_sec_b_line_24)
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
        [
          @direct_file_data.total_qualifying_dependent_care_expenses,
          [12_000 - @direct_file_data.excluded_benefits_amount, 0].max,
          @direct_file_data.primary_earned_income_amount,
          @direct_file_data.spouse_earned_income_amount,
        ].min
      end

      def calculate_sec_b_line_7
        @direct_file_data.fed_taxable_ssb&.round || 0
      end

      def calculate_sec_b_line_18
        @intake.has_health_insurance_premium_yes? ? @intake.health_insurance_paid_amount&.round : 0
      end

      def calculate_sec_b_line_24
        line_or_zero(:ID39R_B_LINE_3) + line_or_zero(:ID39R_B_LINE_6) + line_or_zero(:ID39R_B_LINE_7) + line_or_zero(:ID39R_B_LINE_8f) + line_or_zero(:ID39R_B_LINE_18)
      end
    end
  end
end
