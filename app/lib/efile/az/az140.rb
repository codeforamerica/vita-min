module Efile
  module Az
    class Az140 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, filing_status:, claimed_as_dependent:, dependent_count:, direct_file_data:, include_source: false, federal_dependent_count_under_17:, federal_dependent_count_over_17:)
        @year = year

        @filing_status = filing_status # single, married_filing_jointly, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @dependent_count = dependent_count # number
        @federal_dependent_count_under_17 = federal_dependent_count_under_17
        @federal_dependent_count_over_17 = federal_dependent_count_over_17
        @direct_file_data = direct_file_data
        @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
        @lines = HashWithIndifferentAccess.new
      end

      def calculate
        set_line(:AMT_8, @direct_file_data, :fed_65_primary_spouse)
        set_line(:AMT_9, @direct_file_data, :blind_primary_spouse)
        set_line(:AMT_10A, @federal_dependent_count_under_17)
        set_line(:AMT_10B, @federal_dependent_count_over_17)
        set_line(:AMT_11A, "") # TODO how do we find this information
        set_line(:AMT_10c_first, :dependent_first_name)
        set_line(:AMT_10c_last, :dependent_last_name)
        set_line(:AMT_10c_ssn, :dependent_ssn)
        set_line(:AMT_10c_relationship, :dependent_relationship)
        set_line(:AMT_10c_mo_in_home, :dependent_months_in_home)
        set_line(:AMT_12, @direct_file_data, :fed_agi)
        set_line(:AMT_14, :calculate_line_14)
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_14
        line_or_zero(:AMT_12)
      end

      def calculate_line_10a

      end
    end
  end
end
