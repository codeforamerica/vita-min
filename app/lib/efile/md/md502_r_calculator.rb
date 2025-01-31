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
      end

      private

      def calculate_primary_disabled
        @intake.primary_disabled_yes? ? "X" : nil
      end

      def calculate_spouse_disabled
        return unless @intake.filing_status_mfj?

        @intake.spouse_disabled_yes? ? "X" : nil
      end

      def filer_1099_rs(primary_or_spouse)
        @intake.state_file1099_rs.filter do |state_file_1099_r|
          state_file_1099_r.recipient_ssn == @intake.send(primary_or_spouse).ssn
        end
      end

      def calculate_line_1a
        sum_income_type_for_filer(filer_1099_rs(:primary), :pension_annuity_endowment)
      end

      def calculate_line_1b
        sum_income_type_for_filer(filer_1099_rs(:spouse), :pension_annuity_endowment)
      end

      def sum_income_type_for_filer(filer_1099_rs, income_type)
        filer_1099_rs.sum do |state_file_1099_r|
          if state_file_1099_r.state_specific_followup&.send("income_source_#{income_type}?")
            state_file_1099_r.taxable_amount&.round
          else
            0
          end
        end
      end

      def calculate_line_7a
        sum_income_type_for_filer(filer_1099_rs(:primary), :other)
      end

      def calculate_line_7b
        sum_income_type_for_filer(filer_1099_rs(:spouse), :other)
      end

      def calculate_line_8
        [line_or_zero(:MD502R_LINE_1A), line_or_zero(:MD502R_LINE_1B), line_or_zero(:MD502R_LINE_7A), line_or_zero(:MD502R_LINE_7B)].sum
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
