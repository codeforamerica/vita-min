module Efile
  module Nj
    class Nj2450Calculator < ::Efile::TaxCalculator

      def initialize(value_access_tracker:, lines:, intake:, person:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @person = person
      end

      def calculate
        set_line(:"NJ2450_COLUMN_A_TOTAL_#{primary_or_spouse}", :column_a_total)
        set_line(:"NJ2450_COLUMN_C_TOTAL_#{primary_or_spouse}", :column_c_total)
        set_line(:"NJ2450_COLUMN_A_EXCESS_#{primary_or_spouse}", :column_a_excess)
        set_line(:"NJ2450_COLUMN_C_EXCESS_#{primary_or_spouse}", :column_c_excess)
        @lines.transform_values(&:value)
      end

      private

      def primary_or_spouse
        return 'SPOUSE' if @person.ssn == @intake.spouse.ssn
        'PRIMARY'
      end

      def persons_w2s
        @intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == @person.ssn }
      end

      def column_a_total
        total = persons_w2s.reduce(0) do |sum, w2|
          sum + (w2.box14_ui_hc_wd || 0) + (w2.box14_ui_wf_swf || 0)
        end
        total.round
      end

      def column_c_total
        total = persons_w2s.reduce(0) { |sum, w2| sum + (w2.box14_fli || 0) }
        total.round
      end

      def column_a_excess
        difference = (column_a_total - Nj1040Calculator::EXCESS_UI_WF_SWF_MAX).round
        return difference.round if difference.positive?
      end

      def column_c_excess 
        difference = (column_c_total - Nj1040Calculator::EXCESS_FLI_MAX).round
        return difference.round if difference.positive?
      end
    end
  end
end
