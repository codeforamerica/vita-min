module Efile
  module Az
    class Az140Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @az301 = Efile::Az::Az301Calculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
        @az321 = Efile::Az::Az321Calculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
        @az322 = Efile::Az::Az322Calculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end

      def calculate
        set_line(:AZ140_CCWS_LINE_1c, :calculate_line_1c)
        set_line(:AZ140_CCWS_LINE_2c, :calculate_line_2c)
        set_line(:AZ140_CCWS_LINE_3c, -> { 0 })
        set_line(:AZ140_CCWS_LINE_4c, :calculate_ccws_line_4c)
        set_line(:AZ140_CCWS_LINE_5c, -> { 0 })
        set_line(:AZ140_CCWS_LINE_6c, :calculate_ccws_line_6c)
        set_line(:AZ140_CCWS_LINE_7c, :calculate_ccws_line_7c)
        set_line(:AZ140_LINE_8, :calculate_line_8)
        set_line(:AZ140_LINE_9, @direct_file_data, :blind_primary_spouse)
        set_line(:AZ140_LINE_10A, @intake, :federal_dependent_count_under_17)
        set_line(:AZ140_LINE_10B, @intake, :federal_dependent_count_over_17_non_qualifying_senior)
        set_line(:AZ140_LINE_11A, @intake, :qualifying_parents_and_grandparents)
        set_line(:AZ140_LINE_12, @direct_file_data, :fed_agi)
        set_line(:AZ140_LINE_14, :calculate_line_14)
        set_line(:AZ140_LINE_19, :calculate_line_19)
        set_line(:AZ140_LINE_28, @direct_file_data, :interest_reported_amount)
        set_line(:AZ140_LINE_29A, :calculate_line_29A)
        set_line(:AZ140_LINE_29B, :calculate_line_29B)
        set_line(:AZ140_LINE_30, @direct_file_data, :fed_taxable_ssb)
        set_line(:AZ140_LINE_31, :calculate_line_31)
        set_line(:AZ140_LINE_32, :calculate_line_32)
        set_line(:AZ140_LINE_35, :calculate_line_35)
        set_line(:AZ140_LINE_37, :calculate_line_37)
        set_line(:AZ140_LINE_38, :calculate_line_38)
        set_line(:AZ140_LINE_39, :calculate_line_39)
        set_line(:AZ140_LINE_41, :calculate_line_41)
        set_line(:AZ140_LINE_42, :calculate_line_42)
        set_line(:AZ140_LINE_43, :calculate_line_43)
        set_line(:AZ140_LINE_43S, :calculate_line_43S)
        set_line(:AZ140_LINE_44, :calculate_line_44)
        set_line(:AZ140_LINE_44C, :calculate_line_44C)
        set_line(:AZ140_LINE_45, :calculate_line_45)
        set_line(:AZ140_LINE_46, :calculate_line_46)
        set_line(:AZ140_LINE_47, -> { 0 })
        set_line(:AZ140_LINE_48, :calculate_line_48)
        set_line(:AZ140_LINE_49, :calculate_line_49)
        set_line(:AZ140_LINE_50, :calculate_line_50)
        set_line(:AZ140_LINE_51, -> { 0 })
        set_line(:AZ140_LINE_52, :calculate_line_52)
        set_line(:AZ140_LINE_53, :calculate_line_53)
        set_line(:AZ140_LINE_56, :calculate_line_56)
        set_line(:AZ140_LINE_59, :calculate_line_59)
        if line_or_zero(:AZ140_LINE_52) > line_or_zero(:AZ140_LINE_59)
          set_line(:AZ140_LINE_60, :calculate_line_60)
        else
          set_line(:AZ140_LINE_61, :calculate_line_61)
          set_line(:AZ140_LINE_62, -> { 0 })
          set_line(:AZ140_LINE_63, :calculate_line_63)
        end
        set_line(:AZ140_LINE_79, :calculate_line_79)
        set_line(:AZ140_LINE_80, :calculate_line_80)
        @az321.calculate
        @az322.calculate
        @az301.calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        calculate_line_79 - calculate_line_80
      end

      def analytics_attrs
        {
          dependent_tax_credit: line_or_zero(:AZ140_LINE_49),
          family_income_tax_credit: line_or_zero(:AZ140_LINE_50),
          excise_credit: line_or_zero(:AZ140_LINE_56)
        }
      end

      private

      def calculate_line_1c
        @intake.charitable_cash_amount&.round
      end

      def calculate_line_2c
        @intake.charitable_noncash_amount&.round
      end

      def calculate_line_8
        count = 0
        count += 1 if @intake.primary_senior?
        count += 1 if @intake.filing_status_mfj? && @intake.spouse_senior?
        count
      end

      def calculate_line_14
        line_or_zero(:AZ140_LINE_12)
      end

      def calculate_line_19
        line_or_zero(:AZ140_LINE_14)
      end

      def calculate_line_29A
        # total subtraction amount for pensions up to the maximum of $2,500 each for primary and spouse
        0
      end

      def calculate_line_29B
        # total subtraction amount for uniformed services
        0
      end

      def calculate_line_31
        @intake.tribal_member_yes? ? @intake.tribal_wages_amount&.round : 0
      end

      def calculate_line_32
        @intake.armed_forces_member_yes? ? @intake.armed_forces_wages_amount&.round : 0
      end

      def calculate_line_35
        # Subtotal after additions and subtractions
        subtractions = line_or_zero(:AZ140_LINE_29A) + line_or_zero(:AZ140_LINE_29B)
        (30..32).each do |line_num|
          subtractions += line_or_zero("AZ140_LINE_#{line_num}")
        end
        line_or_zero(:AZ140_LINE_19) - subtractions
      end

      def calculate_line_37
        line_or_zero(:AZ140_LINE_35)
      end

      def calculate_line_38
        line_or_zero(:AZ140_LINE_8) * 2_100
      end

      def calculate_line_39
        line_or_zero(:AZ140_LINE_9) * 1_500
      end

      def calculate_line_41
        line_or_zero(:AZ140_LINE_11A).to_i * 10_000
      end

      def calculate_line_42
        subtractions = 0
        (38..41).each do |line_num|
          subtractions += line_or_zero("AZ140_LINE_#{line_num}").to_i
        end
        [line_or_zero(:AZ140_LINE_37) - subtractions, 0].max
      end

      def calculate_line_43
        # AZ Standard Deductions for 2023
        if filing_status_single?
          13_850
        elsif filing_status_mfj?
          27_700
        elsif filing_status_hoh?
          20_800
        end
      end

      def calculate_line_43S
        'Standard'
      end

      def calculate_line_44
        line_or_zero(:AZ140_CCWS_LINE_7c)
      end

      def calculate_line_44C
        @intake.charitable_contributions_yes? ? "X" : nil
      end

      def calculate_line_45
        taxable_income = line_or_zero(:AZ140_LINE_42)
        deductions_and_charity = line_or_zero(:AZ140_LINE_43) + line_or_zero(:AZ140_LINE_44)
        [taxable_income - deductions_and_charity, 0].max
      end

      def calculate_line_46
        (line_or_zero(:AZ140_LINE_45) * 0.025).round
      end

      def calculate_line_48
        line_or_zero(:AZ140_LINE_46) + line_or_zero(:AZ140_LINE_47)
      end

      def calculate_line_49
        (100 * line_or_zero(:AZ140_LINE_10A)) + (25 * line_or_zero(:AZ140_LINE_10B))
      end

      def calculate_line_50
        # line 42 + line 38 + line 39 + line 40 + line 41
        wrksht_1_line_8 = 0
        (38..42).each do |line_num|
          wrksht_1_line_8 += line_or_zero("AZ140_LINE_#{line_num}").to_i
        end
        wrksht_2_line_2 = 1
        if filing_status_mfj?
          max_income = [
            [1, 20_000],
            [2, 23_600],
            [3, 27_300],
            [Float::INFINITY, 31_000]
          ]
          if wrksht_1_line_8 > max_income.find { |row| @dependent_count <= row[0] }[1]
            return 0
          end
          wrksht_2_line_2 = 2
          wrksht_2_line_5 = 240
        elsif filing_status_hoh? # or qualifying_widow
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

        # worksheet 2
        wrksht_2_line_3 = @dependent_count + wrksht_2_line_2
        wrksht_2_line_4 = wrksht_2_line_3 * 40
        [wrksht_2_line_4, wrksht_2_line_5].min
      end

      def calculate_line_52
        line_52_value = line_or_zero(:AZ140_LINE_48) - (line_or_zero(:AZ140_LINE_49) + line_or_zero(:AZ140_LINE_50) + line_or_zero(:AZ140_LINE_51))
        [line_52_value, 0].max
      end

      # AZ income tax withheld: sum of tax withheld from all income documents: W-2, 1099-R, 1099-G, 1099-INT
      def calculate_line_53
        @intake.state_file_w2s.sum { |item| item.state_income_tax_amount.round } +
          @intake.state_file1099_gs.sum { |item| item.state_income_tax_withheld_amount.round } +
          @intake.state_file1099_rs.sum { |item| item.state_tax_withheld_amount.round }
      end

      def calculate_line_56
        if @intake.disqualified_from_excise_credit_df? || @intake.disqualified_from_excise_credit_fyst?
          0
        else
          # TODO question: if they are filing with us does that automatically mean no AZ-140PTC?
          number_of_filers = filing_status_mfj? ? 2 : 1
          wrksht_line_2 = number_of_filers - @intake.incarcerated_filer_count
          wrksht_line_4 = (@dependent_count + wrksht_line_2) * 25

          max_credit = 100
          max_credit -= @intake.household_excise_credit_claimed_amount&.round if @intake.household_excise_credit_claimed_yes?

          [wrksht_line_4, max_credit].min
        end
      end

      def calculate_line_59
        result = 0
        (53..58).each do |line_num|
          result += line_or_zero("AZ140_LINE_#{line_num}").to_i
        end
        result
      end

      def calculate_line_60
        [line_or_zero(:AZ140_LINE_52) - line_or_zero(:AZ140_LINE_59), 0].max
      end

      def calculate_line_61
        line_or_zero(:AZ140_LINE_59) - line_or_zero(:AZ140_LINE_52)
      end

      def calculate_line_63
        line_or_zero(:AZ140_LINE_61) - line_or_zero(:AZ140_LINE_62)
      end

      def calculate_line_79
        line_or_zero(:AZ140_LINE_63) - line_or_zero(:AZ140_LINE_78)
      end

      def calculate_line_80
        line_or_zero(:AZ140_LINE_60) + line_or_zero(:AZ140_LINE_78)
      end

      def calculate_ccws_line_4c
        line_or_zero(:AZ140_CCWS_LINE_1c) + line_or_zero(:AZ140_CCWS_LINE_2c)
      end

      def calculate_ccws_line_6c
        line_or_zero(:AZ140_CCWS_LINE_4c)
      end

      def calculate_ccws_line_7c
        (line_or_zero(:AZ140_CCWS_LINE_6c) * 0.31).round
      end
    end
  end
end
