module Efile
  module Az
    class Az140 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, filing_status:, claimed_as_dependent:, dependent_count:, input_lines:)
        @year = year

        @filing_status = filing_status # single, married_filing_jointly, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @dependent_count = dependent_count # number
        @value_access_tracker = Efile::ValueAccessTracker.new
        input_lines.each_value { |l| l.value_access_tracker = @value_access_tracker }
        @lines = HashWithIndifferentAccess.new(input_lines)
      end

      def calculate
        set_line(:AMT_14, -> { calculate_line_14 })
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_14
        line_or_zero(:AMT_12)
      end
    end
  end
end
