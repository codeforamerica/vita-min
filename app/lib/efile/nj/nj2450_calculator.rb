module Efile
  module Nj
    class Nj2450Calculator < ::Efile::TaxCalculator
      include StateFile::Nj2450Helper

      def initialize(value_access_tracker:, lines:, intake:, primary_or_spouse:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @primary_or_spouse = primary_or_spouse
      end

      def calculate
        set_line(line_name("NJ2450_COLUMN_A_TOTAL", @primary_or_spouse), :column_a_total)
        set_line(line_name("NJ2450_COLUMN_C_TOTAL", @primary_or_spouse), :column_c_total)
        set_line(line_name("NJ2450_COLUMN_A_EXCESS", @primary_or_spouse), :column_a_excess)
        set_line(line_name("NJ2450_COLUMN_C_EXCESS", @primary_or_spouse), :column_c_excess)
        @lines.transform_values(&:value)
      end

      
      private

      def w2s
        get_persons_w2s(@intake, @primary_or_spouse)
      end

      def column_a_total
        w2s.sum { |w2| w2.get_box14_ui_overwrite || 0 }.round
      end

      def column_c_total
        w2s.sum { |w2| w2.box14_fli || 0 }.round
      end

      def column_a_excess
        max = StateFile::StateInformationService
          .w2_supported_box14_codes("nj")
          .find { |code| code[:name] == "UI_WF_SWF" }[:limit]
        difference = (column_a_total - max).round
        difference.positive? ? difference : 0
      end

      def column_c_excess
        max = StateFile::StateInformationService
          .w2_supported_box14_codes("nj")
          .find { |code| code[:name] == "FLI" }[:limit]
        difference = (column_c_total - max).round
        difference.positive? ? difference : 0
      end
    end
  end
end
