module Efile
  module Nc
    class D400ScheduleSCalculator < ::Efile::TaxCalculator
      attr_reader :lines

      def calculate
        set_line(:NCD400_S_LINE_27, :calculate_line_27)
        set_line(:NCD400_S_LINE_41, :calculate_line_41)
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_27
        @intake.tribal_wages_amount.to_i
      end

      def calculate_line_41
        (17..22).sum { |line_num| line_or_zero("NCD400_SC_LINE_#{line_num}") } + (25..40).sum { |line_num| line_or_zero("NCD400_SC_LINE_#{line_num}") }
      end
    end
  end
end
