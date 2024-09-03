module Efile
  module Nc
    class D400Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def calculate
        set_line(:NCD400_LINE_20A, :calculate_line_20a)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0 # placeholder
      end

      private

      def calculate_line_20a
        @direct_file_data.w2s.reduce(0) do |sum, w2|
          if w2.EmployeeSSN == @direct_file_data.primary_ssn
            sum += w2.StateIncomeTaxAmt
          end
          sum
        end
      end
    end
  end
end
