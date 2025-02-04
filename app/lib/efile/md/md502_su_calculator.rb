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
        set_line(:MD502_SU_LINE_U, :calculate_line_u)
        set_line(:MD502_SU_LINE_U_PRIMARY, :calculate_line_u_primary)
        set_line(:MD502_SU_LINE_U_SPOUSE, :calculate_line_u_spouse)
        set_line(:MD502_SU_LINE_V, :calculate_line_v) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_SU_LINE_1, :calculate_line_1)
      end

      # this will be replaced by arin's method
      def calculate_military_taxable_amount(person)
        applicable_1099_rs = @intake.state_file1099_rs.where.not(state_specific_followup: nil)
        applicable_1099_rs.sum do |state_file1099_r|
          if state_file1099_r.recipient_ssn == @intake.send(person).ssn && state_file1099_r.state_specific_followup.service_type_military?
            state_file1099_r.taxable_amount
          else
            0
          end
        end
      end

      def calculate_military_per_person(person)
        age_benefits = @intake.is_filer_55_and_older?(person) ? 20_000 : 12_500
        [calculate_military_taxable_amount(:primary), age_benefits].min
      end

      def calculate_line_u_primary
        calculate_military_per_person(:primary)
      end

      def calculate_line_u_spouse
        @intake.filing_status_mfj? && @intake.spouse_birth_date.present? ? calculate_military_per_person(:spouse) : 0
      end

      def calculate_line_u
        line_or_zero(:MD502_SU_LINE_U_PRIMARY) + line_or_zero(:MD502_SU_LINE_U_SPOUSE)
      end

      private

      def calculate_line_ab
        @direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end

      def calculate_line_v; end

      def calculate_line_1
        line_or_zero(:MD502_SU_LINE_AB) + line_or_zero(:MD502_SU_LINE_U) + line_or_zero(:MD502_SU_LINE_V)
      end
    end
  end
end
