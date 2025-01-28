module Efile
  module Nc
    class D400ScheduleSCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_data = intake.direct_file_data
      end

      def calculate
        set_line(:NCD400_S_LINE_18, :calculate_line_18)
        set_line(:NCD400_S_LINE_19, @direct_file_data, :fed_taxable_ssb)
        set_line(:NCD400_S_LINE_20, :calculate_line_20)
        set_line(:NCD400_S_LINE_21, :calculate_line_21)
        set_line(:NCD400_S_LINE_27, :calculate_line_27)
        set_line(:NCD400_S_LINE_41, :calculate_line_41)
      end

      private

      def calculate_line_18
        @intake.direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end

      def calculate_line_20
        @intake.state_file1099_rs.sum do |state_file1099_r|
          if state_file1099_r.state_specific_followup.income_source_bailey_settlement? &&
            (state_file1099_r.state_specific_followup.bailey_settlement_at_least_five_years_yes? || state_file1099_r.state_specific_followup.bailey_settlement_from_retirement_plan_yes?)
            state_file1099_r.taxable_amount
          else
            0
          end
        end
      end

      def calculate_line_21
        @intake.state_file1099_rs.sum do |state_file1099_r|
          if state_file1099_r.state_specific_followup.income_source_uniformed_services? &&
            (state_file1099_r.state_specific_followup.uniformed_services_retired_yes? || state_file1099_r.state_specific_followup.uniformed_services_qualifying_plan_yes?)
            state_file1099_r.taxable_amount
          else
            0
          end
        end
      end

      def calculate_line_27
        @intake.tribal_wages_amount.to_i
      end

      def calculate_line_41
        (17..22).sum { |line_num| line_or_zero("NCD400_S_LINE_#{line_num}") } + line_or_zero("NCD400_S_LINE_23F") + line_or_zero("NCD400_S_LINE_24F") + (25..40).sum { |line_num| line_or_zero("NCD400_S_LINE_#{line_num}") }
      end
    end
  end
end
