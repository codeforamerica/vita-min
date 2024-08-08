module Efile
  module Nc
    class D400Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        calculate_line_1 - calculate_line_2
      end

      private

      def calculate_line_1
        1000000
      end

      def calculate_line_2
        0
      end
    end
  end
end
