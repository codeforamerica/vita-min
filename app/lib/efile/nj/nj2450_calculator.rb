module Efile
  module Nj
    class Nj2450Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:NJ2450_COLUMN_A_TOTAL, :column_a_total)
        set_line(:NJ2450_COLUMN_C_TOTAL, :column_c_total)
        set_line(:NJ2450_COLUMN_A_EXCESS, :column_a_excess)
        set_line(:NJ2450_COLUMN_C_EXCESS, :column_c_excess)
        @lines.transform_values(&:value)
      end

      private

      def person
        @kwargs[:person]
      end

      def persons_w2s
        intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == person.ssn }
      end

      def column_a_total
        persons_w2s.reduce(0) { |sum, w2| sum + w2.box14_ui_wf_swf + w2.box14_ui_hc_wd }
      end

      def column_c_total
        persons_w2s.reduce(0) { |sum, w2| sum + w2.box14_fli }
      end

      def column_a_excess
        (column_a_total - Nj1040Calculator::EXCESS_UI_WF_SWF_UI_HC_WD_MAX).round
      end

      def column_c_excess 
        (column_c_total - Nj1040Calculator::EXCESS_FLI_MAX).round
      end
    end
  end
end
