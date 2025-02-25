module Efile
  module Md
    class Md502RCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502R_LINE_PRIMARY_DISABLED, :calculate_primary_disabled)
        set_line(:MD502R_LINE_SPOUSE_DISABLED, :calculate_spouse_disabled)
        set_line(:MD502R_LINE_1A, :calculate_line_1a)
        set_line(:MD502R_LINE_1B, :calculate_line_1b)
        set_line(:MD502R_LINE_7A, :calculate_line_7a)
        set_line(:MD502R_LINE_7B, :calculate_line_7b)
        set_line(:MD502R_LINE_8, :calculate_line_8)
        set_line(:MD502R_LINE_9A, :calculate_line_9a)
        set_line(:MD502R_LINE_9B, :calculate_line_9b)
        set_line(:MD502R_LINE_10A, :calculate_line_10a)
        set_line(:MD502R_LINE_10B, :calculate_line_10b)
        set_line(:MD502R_LINE_11A, :calculate_line_11a)
        set_line(:MD502R_LINE_11B, :calculate_line_11b)
      end

      private

      def calculate_primary_disabled
        @intake.primary_disabled_yes? ? "X" : nil
      end

      def calculate_spouse_disabled
        return unless @intake.filing_status_mfj?

        @intake.spouse_disabled_yes? ? "X" : nil
      end

      def calculate_line_1a
        @intake.sum_1099_r_followup_type_for_filer(:primary, :income_source_pension_annuity_endowment?)
      end

      def calculate_line_1b
        @intake.sum_1099_r_followup_type_for_filer(:spouse, :income_source_pension_annuity_endowment?)
      end

      def calculate_line_7a
        @intake.sum_1099_r_followup_type_for_filer(:primary, :income_source_other?)
      end

      def calculate_line_7b
        @intake.sum_1099_r_followup_type_for_filer(:spouse, :income_source_other?)
      end

      def calculate_line_8
        [line_or_zero(:MD502R_LINE_1A), line_or_zero(:MD502R_LINE_1B), line_or_zero(:MD502R_LINE_7A), line_or_zero(:MD502R_LINE_7B)].sum
      end

      def calculate_line_9a
        if @intake.direct_file_data.fed_ssb.positive?
          if @intake.filing_status_mfj?
            @intake.direct_file_json_data.primary_filer_social_security_benefit_amount&.round || 0
          else
            @intake.direct_file_data.fed_ssb.round
          end
        end
      end

      def calculate_line_9b
        if @intake.filing_status_mfj? && @intake.direct_file_data.fed_ssb.positive?
          @intake.direct_file_json_data.spouse_filer_social_security_benefit_amount&.round
        end
      end

      def calculate_line_10a
        line_or_zero(:MD502_SU_LINE_U_PRIMARY) + line_or_zero(:MD502_SU_LINE_V_PRIMARY)
      end

      def calculate_line_10b
        line_or_zero(:MD502_SU_LINE_U_SPOUSE) + line_or_zero(:MD502_SU_LINE_V_SPOUSE)
      end

      def calculate_line_11(filer)
        letter = filer == :primary ? "A" : "B"
        qualifying_pension_minus_ssn_or_railroad = line_or_zero("MD502R_LINE_1#{letter}".to_sym) - line_or_zero("MD502R_LINE_10#{letter}".to_sym)
        tentative_exclusion = 39_500 - line_or_zero("MD502R_LINE_9#{letter}".to_sym)
        result = [qualifying_pension_minus_ssn_or_railroad, tentative_exclusion].min
        [result, 0].max
      end

      def calculate_line_11a
        if Flipper.enabled?(:show_retirement_ui)
          @intake.qualifies_for_pension_exclusion?(:primary) ? calculate_line_11(:primary) : 0
        else
          0
        end
      end

      def calculate_line_11b
        if Flipper.enabled?(:show_retirement_ui)
          @intake.filing_status_mfj? && @intake.qualifies_for_pension_exclusion?(:spouse) ? calculate_line_11(:spouse) : 0
        else
          0
        end
      end
    end
  end
end
