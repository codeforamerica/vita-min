module Efile
  module Md
    class Md502SuCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502_SU_LINE_AB, :calculate_line_ab)
        set_line(:MD502_SU_LINE_U, :calculate_line_u) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V, :calculate_line_v) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_1, :calculate_line_1)
        set_line(:MD502_SU_LINE_U_PRIMARY, :calculate_line_u_primary) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V_PRIMARY, :calculate_line_v_primary) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_U_SPOUSE, :calculate_line_u_spouse) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V_SPOUSE, :calculate_line_v_spouse) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
      end

      private

      def calculate_line_ab
        @direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end

      def calculate_line_u_primary; end

      def calculate_line_v_primary; end

      def calculate_line_u_spouse; end

      def calculate_line_v_spouse; end

      def calculate_line_u; end

      def calculate_line_v; end

      def calculate_line_1
        line_or_zero(:MD502_SU_LINE_AB) + line_or_zero(:MD502_SU_LINE_U) + line_or_zero(:MD502_SU_LINE_V)
      end
    end
  end
end
