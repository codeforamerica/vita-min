module Efile
  module Md
    class Md502SuCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      CODE_LETTERS = ["AB", "U"]

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502_SU_LINE_AB, :calculate_line_ab)
        set_line(:MD502_SU_LINE_U_PRIMARY, :calculate_line_u_primary)
        set_line(:MD502_SU_LINE_U_SPOUSE, :calculate_line_u_spouse)
        set_line(:MD502_SU_LINE_U, :calculate_line_u)
        set_line(:MD502_SU_LINE_V_PRIMARY, :calculate_line_v_primary) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V_SPOUSE, :calculate_line_v_spouse) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_V, :calculate_line_v) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_1, :calculate_line_1)
      end

      def calculate_military_per_filer(filer)
        age_benefits = @intake.is_filer_55_and_older?(filer) ? 20_000 : 12_500
        [@intake.sum_1099_r_followup_type_for_filer(:primary, :service_type_military?), age_benefits].min
      end

      def calculate_line_u_primary
        calculate_military_per_filer(:primary)
      end

      def calculate_line_u_spouse
        @intake.filing_status_mfj? && @intake.spouse_birth_date.present? ? calculate_military_per_filer(:spouse) : 0
      end

      private

      def calculate_line_ab
        @direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end

      def calculate_line_u
        line_or_zero(:MD502_SU_LINE_U_PRIMARY) + line_or_zero(:MD502_SU_LINE_U_SPOUSE)
      end

      def calculate_line_v_primary; end

      def calculate_line_v_spouse; end

      def calculate_line_v; end

      def calculate_line_1
        line_or_zero(:MD502_SU_LINE_AB) + line_or_zero(:MD502_SU_LINE_U) + line_or_zero(:MD502_SU_LINE_V)
      end
    end
  end
end
