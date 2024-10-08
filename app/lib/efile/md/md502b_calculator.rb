module Efile
  module Md
    class Md502bCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
      end

      def calculate
        set_line(:MD502B_LINE_1, :calculate_line_1)
        set_line(:MD502B_LINE_2, :calculate_line_2)
        set_line(:MD502B_LINE_3, :calculate_line_3)
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_1
        @intake.dependents.filter { |dependent| !dependent.senior? }.count
      end

      def calculate_line_2
        @intake.dependents.filter { |dependent| dependent.senior? }.count
      end

      def calculate_line_3
        line_or_zero(:MD502B_LINE_1) + line_or_zero(:MD502B_LINE_2)
      end
    end
  end
end
