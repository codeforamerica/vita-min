module Efile
  module Az
    class Az140 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, filing_status:, claimed_as_dependent:, intake:, dependent_count:, direct_file_data:, include_source: false, federal_dependent_count_under_17:, federal_dependent_count_over_17:, sentenced_for_60_days:)
        @year = year

        @filing_status = filing_status # single, married_filing_jointly, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @intake = intake
        @dependent_count = dependent_count # number
        @federal_dependent_count_under_17 = federal_dependent_count_under_17
        @federal_dependent_count_over_17 = federal_dependent_count_over_17
        @sentenced_for_60_days = sentenced_for_60_days
        @direct_file_data = direct_file_data
        @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
        @lines = HashWithIndifferentAccess.new
      end

      def calculate
        set_line(:AMT_97, @intake, :prior_last_names)
        set_line(:AMT_8, @direct_file_data, :fed_65_primary_spouse)
        set_line(:AMT_9, @direct_file_data, :blind_primary_spouse)
        set_line(:AMT_10A, -> { @federal_dependent_count_under_17 })
        set_line(:AMT_10B, -> { @federal_dependent_count_over_17 })
        set_line(:AMT_11A, -> { "" }) # TODO Tie up dependent information once we know if we have access to fed database or just 1040
        set_line(:AMT_10c_first, @direct_file_data, :first_dependent_first_name)
        set_line(:AMT_10c_middle, -> { "" }) # TODO Tie up dependent information
        set_line(:AMT_10c_last, @direct_file_data, :first_dependent_last_name)
        set_line(:AMT_10c_ssn, @direct_file_data, :first_dependent_ssn)
        set_line(:AMT_10c_relationship, @direct_file_data, :first_dependent_relationship)
        set_line(:AMT_10c_mo_in_home, @direct_file_data, :first_dependent_months_in_home)
        set_line(:AMT_10c_under_17, -> { "X" }) # TODO Tie up dependent information
        set_line(:AMT_10c_over_17, -> { "" }) # TODO Tie up dependent information
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
        set_line(:AMT_47, -> { 0 })
        set_line(:AMT_48, :calculate_line_48)
        set_line(:AMT_49, :calculate_line_49)
        set_line(:AMT_50, :calculate_line_50)
        set_line(:AMT_51, -> { 0 })
        set_line(:AMT_52, :calculate_line_52)
        set_line(:AMT_53, -> { 0 }) # included in 1040?
        set_line(:AMT_56, :calculate_line_56)
        set_line(:AMT_59, :calculate_line_59)
        if line_or_zero(:AMT_52) > line_or_zero(:AMT_59)
          set_line(:AMT_60, :calculate_line_60)
        else
          set_line(:AMT_61, :calculate_line_61)
          set_line(:AMT_62, -> { 0 })
          set_line(:AMT_63, :calculate_line_63)
        end
        if (line_or_zero(:AMT_63) - line_or_zero(:AMT_78)) >= 0
          set_line(:AMT_79, :calculate_line_79)
        else
          set_line(:AMT_80, :calculate_line_80)
        end
        set_line(:AMT_79, :calculate_line_79)
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_1c, @intake, :charitable_cash)
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_2c, @intake, :charitable_noncash)
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_3c, -> { 0 })
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_4c, :calculate_charitable_contributions_worksheet_4c)
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_5c, -> { 0 })
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_6c, :calculate_charitable_contributions_worksheet_6c)
        set_line(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_7c, :calculate_charitable_contributions_worksheet_7c)
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
        (30..32).each do |line_num|
          # Lines 31 and 32 are only included if there is time to as it is labeled as a maybe
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
        line_or_zero(:AMT_11A).to_i * 10_000
      end

      def calculate_line_42
        subtractions = 0
        (38..41).each do |line_num|
          subtractions += line_or_zero("AMT_#{line_num}").to_i
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
        line_or_zero(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_7c)
      end

      def calculate_line_44C
        if line_or_zero(:AMT_44).positive?
          "X" # TODO figure out checkmarks on PDF
        end
      end

      def calculate_line_45
        subtractions = 0
        (33..44).each do |line_num|
          subtractions += line_or_zero("AMT_#{line_num}").to_i
        end
        [line_or_zero(:AMT_42) - subtractions, 0].max
      end

      def calculate_line_46
        if filing_status_single?
          if line_or_zero(:AMT_45) <= 28653
            (line_or_zero(:AMT_45) * 0.0255).round
          elsif line_or_zero(:AMT_45) > 28653
            (((line_or_zero(:AMT_45) - 28653) * 0.0298) + 731).round
          end
        elsif filing_status_mfj? || filing_status_hoh?
          if line_or_zero(:AMT_45) <= 57305
            (line_or_zero(:AMT_45) * 0.0255).round
          elsif line_or_zero(:AMT_45) > 57305
            (((line_or_zero(:AMT_45) - 57305) * 0.0298) + 1461).round
          end
        end
      end

      def calculate_line_48
        line_or_zero(:AMT_46) + line_or_zero(:AMT_47)
      end

      def calculate_line_49
        (100 * line_or_zero(:AMT_10A)) + (25 * line_or_zero(:AMT_10B))
      end

      def calculate_line_50
        # line 42 + line 38 + line 39 + line 40 + line 41
        wrksht_1_line_8 = 0
        (38..42).each do |line_num|
          wrksht_1_line_8 += line_or_zero("AMT_#{line_num}").to_i
        end
        wrksht_2_line_2 = 1
        if filing_status_mfj?
          max_income = [
            [1, 20_000],
            [2, 23_600],
            [3, 27_300],
            [Float::INFINITY, 31_000]
          ]
          if wrksht_1_line_8 > max_income.find { |row| @dependent_count <= row[0] }
            return 0
          end
          wrksht_2_line_2 = 2
          wrksht_2_line_5 = 240
        elsif filing_status_hoh?
          max_income = [
            [1, 20_000],
            [2, 20_135],
            [3, 23_800],
            [4, 25_200],
            [Float::INFINITY, 26_575]
          ]
          if wrksht_1_line_8 > max_income.find { |row| @dependent_count <= row[0] }[1]
            return 0
          end
          wrksht_2_line_5 = 240
        else
          if wrksht_1_line_8 > 10_000
            return 0
          end
          wrksht_2_line_5 = 120
        end

        #wrksheet 2
        wrksht_2_line_3 = @dependent_count + wrksht_2_line_2
        wrksht_2_line_4 = wrksht_2_line_3 * 40
        [wrksht_2_line_4, wrksht_2_line_5].min
      end

      def calculate_line_52
        line_52_value = line_or_zero(:AMT_48) - (line_or_zero(:AMT_49) + line_or_zero(:AMT_50) + line_or_zero(:AMT_51))
        [line_52_value, 0].max
      end

      def calculate_line_56
        if @direct_file_data.primary_ssn.present? && !@claimed_as_dependent && !@sentenced_for_60_days
          # todo question: if they are filing with us does that automatically mean no AZ-140PTC?
          if filing_status_mfj? || filing_status_hoh?
            return 0 unless line_or_zero(:AMT_12) <= 25000
          elsif filing_status_single?
            return 0 unless line_or_zero(:AMT_12) <= 12500
          end
          wrksht_line_2 = filing_status_mfj? ? 2 : 1
          wrksht_line_4 = (@dependent_count + wrksht_line_2) * 25
          return [wrksht_line_4, 100].min
        end

        0
      end

      def calculate_line_59
        result = 0
        (53..58).each do |line_num|
          result += line_or_zero("AMT_#{line_num}").to_i
        end
        result
      end

      def calculate_line_60
        [line_or_zero(:AMT_52) - line_or_zero(:AMT_59), 0].max
      end

      def calculate_line_61
        line_or_zero(:AMT_59) - line_or_zero(:AMT_52)
      end

      def calculate_line_63
        line_or_zero(:AMT_61) - line_or_zero(:AMT_62)
      end

      def calculate_line_79
        line_or_zero(:AMT_63) - line_or_zero(:AMT_78)
      end

      def calculate_line_80
        line_or_zero(:AMT_60) + line_or_zero(:AMT_78)
      end

      def calculate_charitable_contributions_worksheet_4c
        line_or_zero(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_1c) + line_or_zero(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_2c)
      end

      def calculate_charitable_contributions_worksheet_6c
        line_or_zero(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_4c)
      end

      def calculate_charitable_contributions_worksheet_7c
        (line_or_zero(:CHARITABLE_CONTRIBUTIONS_WORKSHEET_6c) * 0.27).round
      end
    end
  end
end
