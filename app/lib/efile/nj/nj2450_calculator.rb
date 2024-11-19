module Efile
  module Nj
    class Nj2450Calculator < ::Efile::TaxCalculator
      include StateFile::Nj2450Helper

      def initialize(value_access_tracker:, lines:, intake:, primary_or_spouse:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @primary_or_spouse = primary_or_spouse
        @w2s = get_persons_w2s(intake, @primary_or_spouse)
      end

      def calculate
        set_line(line_name("NJ2450_COLUMN_A_TOTAL", @primary_or_spouse), :column_a_total)
        set_line(line_name("NJ2450_COLUMN_C_TOTAL", @primary_or_spouse), :column_c_total)
        set_line(line_name("NJ2450_COLUMN_A_EXCESS", @primary_or_spouse), :column_a_excess)
        set_line(line_name("NJ2450_COLUMN_C_EXCESS", @primary_or_spouse), :column_c_excess)
        @lines.transform_values(&:value)
      end

      
      private

      def column_a_total
        total = @w2s.reduce(0) do |sum, w2|
          sum + (w2.box14_ui_hc_wd || 0) + (w2.box14_ui_wf_swf || 0)
        end
        total.round
      end

      def column_c_total
        total = @w2s.reduce(0) { |sum, w2| sum + (w2.box14_fli || 0) }
        total.round
      end

      def column_a_excess
        difference = (column_a_total - Nj1040Calculator::EXCESS_UI_WF_SWF_MAX).round
        difference.positive? ? difference.round : 0
      end

      def column_c_excess 
        difference = (column_c_total - Nj1040Calculator::EXCESS_FLI_MAX).round
        difference.positive? ? difference.round : 0
      end
    end
  end
end
