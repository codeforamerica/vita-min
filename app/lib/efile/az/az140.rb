module Efile
  module Az
    class Az140 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, filing_status:, claimed_as_dependent:, dependent_count:, direct_file_data:, include_source: false)
        @year = year

        @filing_status = filing_status # single, married_filing_jointly, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @dependent_count = dependent_count # number
        @direct_file_data = direct_file_data
        @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
        @lines = HashWithIndifferentAccess.new
      end

      def calculate
        set_line(:AMT_12, @direct_file_data, :fed_agi)
        set_line(:AMT_14, :calculate_line_14)
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_14
        line_or_zero(:AMT_12)
      end
    end
  end
end
