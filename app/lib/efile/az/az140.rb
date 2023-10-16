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
        set_line(:AMT_19, :calculate_line_19)
        set_line(:AMT_30, @direct_file_data, :fed_taxable_ssb)
        set_line(:AMT_35, :calculate_line_35)
        set_line(:AMT_37, :calculate_line_37)
        set_line(:AMT_38, :calculate_line_38)
        set_line(:AMT_39, :calculate_line_39)
        set_line(:AMT_41, :calculate_line_41)
        set_line(:AMT_42, :calculate_line_42)
        set_line(:AMT_43, :calculate_line_43)
        set_line(:AMT_43S, -> { "X" }) # TODO if this the way to mark an x on the box?
        set_line(:AMT_44, :calculate_line_44)
        set_line(:AMT_44C, :calculate_line_44C)
        set_line(:AMT_45, :calculate_line_45)
        set_line(:AMT_46, :calculate_line_46)
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_14
        line_or_zero(:AMT_12)
      end

      def calculate_line_19
        line_or_zero(:AMT_14)
      end

      def calculate_line_35
        subtractions = 0
        (30..32).each do |line_num| # Lines 31 and 32 are only included if there is time to as it is labeled as a maybe
          subtractions += line_or_zero("AMT_#{line_num}")
        end
        line_or_zero(:AMT_19) - subtractions
      end

      def calculate_line_37
        line_or_zero(:AMT_35)
      end

      def calculate_line_38
        line_or_zero(:AMT_8) * 2_100
      end

      def calculate_line_39
        line_or_zero(:AMT_9) * 1_500
      end

      def calculate_line_41
        line_or_zero(:AMT_11A) * 10_000
      end

      def calculate_line_42
        subtractions = 0
        (38..41).each do |line_num|
          subtractions += line_or_zero("AMT_#{line_num}")
        end
        [line_or_zero(:AMT_37) - subtractions, 0].max
      end

      def calculate_line_43
        if filing_status_single?
          12950
        elsif filing_status_mfj?
          25900
        elsif filing_status_hoh?
          19400
        end
      end

      def calculate_line_44
        # TODO Need to figure out page 3 worksheet math if these values are from the client
      end

      def calculate_line_44C
        # TODO Need to figure out page 3 worksheet math if these values are from the client
      end

      def calculate_line_45
        subtractions = 0
        (33..44).each do |line_num|
          subtractions += line_or_zero("AMT_#{line_num}")
        end
        [line_or_zero(:AMT_42) - subtractions, 0].max
      end

      def calculate_line_46
        if filing_status_single?
          if line_or_zero(:AMT_45) <= 28653
            line_or_zero(:AMT_45) * 0.0255
          elsif line_or_zero(:AMT_45) > 28653
            ((line_or_zero(:AMT_45) - 28653) * 0.0298) + 731
          end
          if filing_status_mfj?  || filing_status_hoh?
            if line_or_zero(:AMT_45) <= 57305
              line_or_zero(:AMT_45) * 0.0255
            elsif line_or_zero(:AMT_45) > 57305
              ((line_or_zero(:AMT_45) - 57305) * 0.0298) + 1461
            end
          end
        end
      end
    end
  end
end
