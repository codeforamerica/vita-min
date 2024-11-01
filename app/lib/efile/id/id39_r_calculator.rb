module Efile
  module Id
    class Id39RCalculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:ID39R_B_LINE_3, :calculate_sec_b_line_3)
        set_line(:ID39R_B_LINE_18, :calculate_sec_b_line_18)
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

      def calculate_sec_b_line_18
        @intake.has_health_insurance_premium_yes? ? @intake.health_insurance_paid_amount&.round : 0
      end
    end
  end
end
