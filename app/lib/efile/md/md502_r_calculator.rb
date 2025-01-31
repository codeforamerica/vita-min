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
        set_line(:MD502R_LINE_9A, :calculate_line_9a)
        set_line(:MD502R_LINE_9B, :calculate_line_9b)
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
        sum_pension_annuity_endowment(filer_1099_rs(:primary))
      end

      def calculate_line_1b
        sum_pension_annuity_endowment(filer_1099_rs(:spouse))
      end

      def filer_1099_rs(primary_or_spouse)
        @intake.state_file1099_rs.filter do |state_file_1099_r|
          state_file_1099_r.recipient_ssn == @intake.send(primary_or_spouse).ssn
        end
      end

      def sum_pension_annuity_endowment(filer_1099_rs)
        filer_1099_rs.sum do |state_file_1099_r|
          if state_file_1099_r.state_specific_followup&.income_source_pension_annuity_endowment?
            state_file_1099_r.taxable_amount&.round
          else
            0
          end
        end
      end

      def calculate_line_9a
        if @intake.direct_file_data.fed_ssb.positive?
          if @intake.filing_status_mfj?
            @intake.primary_ssb_amount&.round || 0
          else
            @intake.direct_file_data.fed_ssb.round
          end
        end
      end

      def calculate_line_9b
        if @intake.filing_status_mfj? && @intake.direct_file_data.fed_ssb.positive? && @intake.spouse_ssb_amount.present?
          @intake.spouse_ssb_amount.round
        end
      end
    end
  end
end
