module Efile
  module Md
    class Md502SuCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502_SU_LINE_AB, :calculate_line_ab)
        set_line(:MD502_SU_LINE_U, :calculate_line_u) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V, :calculate_line_v) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_1, :calculate_line_1)
      end

      private

      def calculate_line_ab
        @direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end

      def calculate_line_u
        @intake.state_file1099_rs.where.not(state_specific_followup: nil).sum do |state_file1099_r|
          state_file1099_r.state_specific_followup.service_type_military? ? state_file1099_r.taxable_amount : 0
        end
      end

      def calculate_line_v; end

      def calculate_line_1
        line_or_zero(:MD502_SU_LINE_AB) + line_or_zero(:MD502_SU_LINE_U) + line_or_zero(:MD502_SU_LINE_V)
      end
    end
  end
end
