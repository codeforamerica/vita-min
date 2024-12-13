module Efile
  module Md
    class Md502Calculator < ::Efile::TaxCalculator
      attr_reader :lines
      set_refund_owed_lines refund: :MD502_LINE_48, owed: :MD502_LINE_50

      def initialize(year:, intake:, include_source: false)
        super
        @md502b = Efile::Md::Md502bCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )

        @md502_su = Efile::Md::Md502SuCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )

        @two_income_subtraction_worksheet = Efile::Md::TwoIncomeSubtractionWorksheet.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )

        @md502cr = Efile::Md::Md502crCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end

      def calculate
        # Exemptions
        set_line(:MD502_LINE_A_PRIMARY, :calculate_line_a_primary)
        set_line(:MD502_LINE_A_SPOUSE, :calculate_line_a_spouse)
        set_line(:MD502_LINE_A_COUNT, :calculate_line_a_count)
        set_line(:MD502_LINE_A_AMOUNT, :calculate_line_a_amount)
        set_line(:MD502_LINE_B_PRIMARY_SENIOR, :calculate_line_b_primary_senior)
        set_line(:MD502_LINE_B_SPOUSE_SENIOR, :calculate_line_b_spouse_senior)
        set_line(:MD502_LINE_B_PRIMARY_BLIND, :calculate_line_b_primary_blind)
        set_line(:MD502_LINE_B_SPOUSE_BLIND, :calculate_line_b_spouse_blind)
        set_line(:MD502_LINE_B_COUNT, :calculate_line_b_count)
        set_line(:MD502_LINE_B_AMOUNT, :calculate_line_b_amount)
        @md502b.calculate
        set_line(:MD502_LINE_C_COUNT, :calculate_line_c_count)
        set_line(:MD502_LINE_C_AMOUNT, :calculate_line_c_amount)
        set_line(:MD502_LINE_D_COUNT_TOTAL, :calculate_line_d_count_total)
        set_line(:MD502_LINE_D_AMOUNT_TOTAL, :calculate_line_d_amount_total)

        # Income
        set_line(:MD502_LINE_1, @direct_file_data, :fed_agi)
        set_line(:MD502_LINE_1A, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1B, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1D, @direct_file_data, :fed_taxable_pensions)
        set_line(:MD502_LINE_1E, :calculate_line_1e)

        # Additions
        set_line(:MD502_LINE_3, :calculate_line_3)
        set_line(:MD502_LINE_6, :calculate_line_6)
        set_line(:MD502_LINE_7, :calculate_line_7)

        # Subtractions
        set_line(:MD502_LINE_9, @direct_file_data, :total_qualifying_dependent_care_expenses_or_limit_amt)
        set_line(:MD502_LINE_10A, :calculate_line_10a) # STUBBED: PLEASE REPLACE, don't forget line_data.yml
        set_line(:MD502_LINE_11, @direct_file_data, :fed_taxable_ssb)
        @md502_su.calculate
        set_line(:MD502_LINE_13, :calculate_line_13)
        if filing_status_mfj?
          @two_income_subtraction_worksheet.calculate
        end
        set_line(:MD502_LINE_14, :calculate_line_14)
        # lines 15 and 16 depend on lines 8-14
        set_line(:MD502_LINE_15, :calculate_line_15)
        set_line(:MD502_LINE_16, :calculate_line_16)

        # Deductions
        set_line(:MD502_DEDUCTION_METHOD, :calculate_deduction_method)
        set_line(:MD502_LINE_17, :calculate_line_17)
        set_line(:MD502_LINE_18, :calculate_line_18)
        set_line(:MD502_LINE_19, :calculate_line_19)
        set_line(:MD502_LINE_20, :calculate_line_20)
        set_line(:MD502_LINE_21, :calculate_line_21)
        @md502cr.calculate # md502cr calculations dependent on line 1 and line 21

        # EIC
        set_line(:MD502_LINE_22, :calculate_line_22)
        set_line(:MD502_LINE_22B, :calculate_line_22b)

        set_line(:MD502_LINE_23, :calculate_line_23)
        set_line(:MD502_LINE_24, :calculate_line_24)
        set_line(:MD502_LINE_26, :calculate_line_26)
        set_line(:MD502_LINE_27, :calculate_line_27)

        # Local tax
        set_line(:MD502_LINE_28_LOCAL_TAX_RATE, :calculate_line_28_local_tax_rate)
        set_line(:MD502_LINE_28_LOCAL_TAX_AMOUNT, :calculate_line_28_local_tax_amount)
        set_line(:MD502_LINE_29, :calculate_line_29)
        set_line(:MD502_LINE_30, :calculate_line_30)
        set_line(:MD502_LINE_32, :calculate_line_32)
        set_line(:MD502_LINE_33, :calculate_line_33)
        set_line(:MD502_LINE_34, :calculate_line_34)
        set_line(:MD502_LINE_39, :calculate_line_39)
        set_line(:MD502_LINE_40, :calculate_line_40)
        set_line(:MD502_LINE_43, :calculate_line_43)
        set_line(:MD502_LINE_42, :calculate_line_42)
        set_line(:MD502_LINE_43, :calculate_line_43)
        set_line(:MD502_LINE_44, :calculate_line_44)
        set_line(:MD502_LINE_45, :calculate_line_45)
        set_line(:MD502_LINE_46, :calculate_line_46)
        set_line(:MD502_LINE_48, :calculate_line_48)
        set_line(:MD502_LINE_50, :calculate_line_50)
        set_line(:MD502_AUTHORIZE_DIRECT_DEPOSIT, @intake, :bank_authorization_confirmed_yes?)
        @md502cr.calculate
        @lines.transform_values(&:value)
      end

      def analytics_attrs
        {}
      end

      private

      def calculate_line_a_primary
        @direct_file_data.claimed_as_dependent? ? nil : "X"
      end

      def calculate_line_a_spouse
        filing_status_mfj? ? "X" : nil
      end

      def calculate_exemption_amount
        # Exemption amount
        income_ranges = if filing_status_single? || filing_status_mfs?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 1600],
                            [125_001..150_000, 800],
                            [150_001..Float::INFINITY, 0]
                          ]
                        elsif filing_status_hoh? || filing_status_mfj? || filing_status_qw?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 3200],
                            [125_001..150_000, 3200],
                            [150_001..175_000, 1600],
                            [175_001..200_000, 800],
                            [200_001..Float::INFINITY, 0]
                          ]
                        else
                          [[-Float::INFINITY..Float::INFINITY, 0]]
                        end

        income_range_index = income_ranges.find_index { |(range, _)| range.include?(@direct_file_data.fed_agi) }

        income_ranges[income_range_index][1]
      end

      def calculate_line_a_count
        [@lines[:MD502_LINE_A_PRIMARY]&.value, @lines[:MD502_LINE_A_SPOUSE]&.value,].count(&:itself)
      end

      def calculate_line_a_amount
        calculate_exemption_amount * line_or_zero(:MD502_LINE_A_COUNT)
      end

      def calculate_line_b_primary_senior
        @intake.primary_senior? ? "X" : nil
      end

      def calculate_line_b_spouse_senior
        return nil unless filing_status_mfj? || filing_status_qw?

        @intake.spouse_senior? ? "X" : nil
      end

      def calculate_line_b_primary_blind
        @direct_file_data.is_primary_blind? ? "X" : nil
      end

      def calculate_line_b_spouse_blind
        return nil unless filing_status_mfj? || filing_status_qw?

        @direct_file_data.is_spouse_blind? ? "X" : nil
      end

      def calculate_line_b_count
        [
          @lines[:MD502_LINE_B_PRIMARY_SENIOR]&.value,
          @lines[:MD502_LINE_B_SPOUSE_SENIOR]&.value,
          @lines[:MD502_LINE_B_PRIMARY_BLIND]&.value,
          @lines[:MD502_LINE_B_SPOUSE_BLIND]&.value
        ].count(&:itself)
      end

      def calculate_line_b_amount
        line_or_zero(:MD502_LINE_B_COUNT) * 1000
      end

      def calculate_line_c_count
        # dependent exemption count
        @lines[:MD502B_LINE_3].value
      end

      def calculate_line_c_amount
        # dependent exemption amount
        calculate_exemption_amount * line_or_zero(:MD502_LINE_C_COUNT)
      end

      def calculate_line_d_count_total
        # Add line A, B and C counts
        line_or_zero(:MD502_LINE_A_COUNT) + line_or_zero(:MD502_LINE_B_COUNT) + line_or_zero(:MD502_LINE_C_COUNT)
      end

      def calculate_line_d_amount_total
        # Add line A, B and C amounts
        line_or_zero(:MD502_LINE_A_AMOUNT) + line_or_zero(:MD502_LINE_B_AMOUNT) + line_or_zero(:MD502_LINE_C_AMOUNT)
      end

      def calculate_line_1e
        total_interest = @direct_file_data.fed_taxable_income + @direct_file_data.fed_tax_exempt_interest
        total_interest > 11_600
      end

      def calculate_line_3
        # State retirement pickup
        @intake.state_file_w2s.sum { |item| (item.box14_stpickup || 0) }.round(0)
      end

      def calculate_line_6
        # Total additions: add lines 2 - 5 (line 2, 4, 5 out of scope)
        line_or_zero(:MD502_LINE_3)
      end

      def calculate_line_7
        # Total federal AGI and Maryland additions: add line 1 and line 6
        line_or_zero(:MD502_LINE_1) + line_or_zero(:MD502_LINE_6)
      end

      def calculate_line_10a; end

      def calculate_line_13
        @lines[:MD502_SU_LINE_1].value
      end

      def calculate_line_14
        line_or_zero(:MD_TWO_INCOME_WK_LINE_7)
      end

      def calculate_line_15
        [
          line_or_zero(:MD502_LINE_9),
          line_or_zero(:MD502_LINE_10A),
          line_or_zero(:MD502_LINE_11),
          line_or_zero(:MD502_LINE_13),
          line_or_zero(:MD502_LINE_14),
        ].sum
      end

      def calculate_line_16
        line_or_zero(:MD502_LINE_7) - line_or_zero(:MD502_LINE_15)
      end

      FILING_MINIMUMS_NON_SENIOR = {
        single: 14_600,
        dependent: 14_600,
        married_filing_jointly: 29_200,
        married_filing_separately: 14_600,
        head_of_household: 21_900,
        qualifying_widow: 29_200
      }

      FILING_MINIMUMS_SENIOR = {
        single: 16_550,
        dependent: 16_550,
        married_filing_jointly: 30_750,
        married_filing_separately: 14_600,
        head_of_household: 23_850,
        qualifying_widow: 30_750
      }

      def calculate_deduction_method
        gross_income_amount = if @direct_file_data.claimed_as_dependent?
                                (@direct_file_data.fed_agi + line_or_zero(:MD502_LINE_6)) - line_or_zero(:MD502_LINE_15)
                              else
                                (@direct_file_data.fed_agi - @direct_file_data.fed_taxable_ssb) + line_or_zero(:MD502_LINE_6)
                              end

        filing_minimum = if @intake.primary_senior? && @intake.filing_status_mfj? && @intake.spouse_senior?
                           32_300
                         elsif @intake.primary_senior?
                           FILING_MINIMUMS_SENIOR[@intake.filing_status]
                         else
                           FILING_MINIMUMS_NON_SENIOR[@intake.filing_status]
                         end

        if gross_income_amount >= filing_minimum
          "S"
        else
          "N"
        end
      end

      DEDUCTION_TABLES = {
        s_mfs_d: {
          12000 => 1_800,
          17999 => ->(x) { (x * 0.15).round },
          Float::INFINITY => 2_700,
        },
        mfj_hoh_qss: {
          24333 => 3_650,
          36332 => ->(x) { (x * 0.15).round },
          Float::INFINITY => 5_450,
        }
      }.freeze
      FILING_STATUS_GROUPS = {
        s_mfs_d: [:single, :married_filing_separately, :dependent],
        mfj_hoh_qss: [:married_filing_jointly, :head_of_household, :qualifying_widow]
      }.freeze

      def calculate_line_17
        if deduction_method_is_standard?
          status_group_key = FILING_STATUS_GROUPS.find { |_, group| group.include?(@intake.filing_status) }[0]
          deduction_table = DEDUCTION_TABLES[status_group_key]
          md_agi = line_or_zero(:MD502_LINE_16)
          amount_or_method = deduction_table.find { |agi_limit, _| md_agi <= agi_limit }[1]
          if amount_or_method.is_a?(Proc)
            amount_or_method.call(md_agi)
          else
            amount_or_method
          end
        else
          0
        end
      end

      def calculate_line_18
        if deduction_method_is_standard?
          line_or_zero(:MD502_LINE_16) - line_or_zero(:MD502_LINE_17)
        else
          0
        end
      end

      def calculate_line_19
        if deduction_method_is_standard?
          line_or_zero(:MD502_LINE_D_AMOUNT_TOTAL)
        else
          0
        end
      end

      def calculate_line_20
        if deduction_method_is_standard?
          [line_or_zero(:MD502_LINE_18) - line_or_zero(:MD502_LINE_19), 0].max
        else
          0
        end
      end

      def calculate_line_21
        # Maryland state income tax
        taxable_net_income = line_or_zero(:MD502_LINE_20)

        if deduction_method_is_standard? && taxable_net_income >= 0

          ranges = if taxable_net_income < 3_000
                     [
                       [0..1_000, 0, 0.02],
                       [1_000..2_000, 20, 0.03],
                       [2_000..3_000, 50, 0.04],
                     ]
                   elsif filing_status_single? || filing_status_mfs? || filing_status_dependent?
                     [
                       [3_000..100_000, 90, 0.0475],
                       [100_000..125_000, 4_697.5, 0.05],
                       [125_000..150_000, 5_947.5, 0.0525],
                       [150_000..250_000, 7_260, 0.055],
                       [250_000..Float::INFINITY, 12_760, 0.0575]
                     ]
                   else # mfj, hoh or qw
                     [
                       [3_000..150_000, 90, 0.0475],
                       [150_000..175_000, 7_072.5, 0.05],
                       [175_000..225_000, 8_322.5, 0.0525],
                       [225_000..300_000, 10_947.5, 0.055],
                       [300_000..Float::INFINITY, 15_072.5, 0.0575]
                     ]
                   end
          range_index = ranges.find_index { |(range, _)| range.include?(taxable_net_income) }

          base = ranges[range_index][1]
          percent = ranges[range_index][2]
          in_excess_of = ranges[range_index][0].begin
          (base + ((taxable_net_income - in_excess_of) * percent)).round
        end
      end

      def calculate_line_22
        # Earned Income Credit (EIC)
        if filing_status_mfj? || filing_status_mfs? || @direct_file_data.fed_eic_qc_claimed
          (@direct_file_data.fed_eic * 0.50).round
        elsif filing_status_single? || filing_status_hoh? || filing_status_qw?
          @direct_file_data.fed_eic.round
        end
      end

      def calculate_line_22b
        (@direct_file_data.fed_eic_qc_claimed && line_or_zero(:MD502_LINE_22).positive?) ? "X" : nil
      end

      def calculate_line_23
        return 0 if filing_status_dependent? || @lines[:MD502_LINE_1B].value <= 0

        comparison_amount = [@lines[:MD502_LINE_7].value, @lines[:MD502_LINE_1B].value].max

        household_size = @intake.dependents.count + (filing_status_mfj? ? 2 : 1)
        poverty_threshold = case household_size
                            when 1 then 15_060
                            when 2 then 20_440
                            when 3 then 25_820
                            when 4 then 31_200
                            when 5 then 36_580
                            when 6 then 41_960
                            when 7 then 47_340
                            when 8 then 52_720
                            else
                              52_720 + ((household_size - 8) * 5_380)
                            end

        if comparison_amount < poverty_threshold
          (@lines[:MD502_LINE_1B].value * 0.05).round
        else
          0
        end
      end

      def calculate_line_24
        line_or_zero(:MD502CR_PART_AA_LINE_14)
      end

      def calculate_line_26
        (22..25).sum { |line_num| line_or_zero("MD502_LINE_#{line_num}") }
      end

      def calculate_line_27
        [line_or_zero(:MD502_LINE_21) - line_or_zero(:MD502_LINE_26), 0].max
      end

      def calculate_line_28_local_tax_rate
        tax_rate = case @intake.residence_county
                   when "Allegany", "Carroll", "Charles"
                     0.0303
                   when "Baltimore City", "Baltimore County", "Caroline", "Dorchester", "Howard", "Kent", "Montgomery", "Prince George's", "Queen Anne's", "Somerset", "Wicomico"
                     0.0320
                   when "Calvert", "St. Mary's"
                     0.0300
                   when "Cecil"
                     0.0275
                   when "Garrett"
                     0.0265
                   when "Harford"
                     0.0306
                   when "Talbot"
                     0.0240
                   when "Washington"
                     0.0295
                   when "Worcester"
                     0.0225
                   when "Anne Arundel"
                     0.027
                   when "Frederick"
                     taxable_net_income = line_or_zero(:MD502_LINE_20)
                     if filing_status_dependent? || filing_status_single? || filing_status_mfs?
                       if taxable_net_income <= 25_000
                         0.0225
                       elsif taxable_net_income <= 50_000
                         0.0275
                       elsif taxable_net_income <= 150_000
                         0.0296
                       else
                         0.032
                       end
                     elsif filing_status_mfj? || filing_status_hoh? || filing_status_qw?
                       if taxable_net_income <= 25_000
                         0.0225
                       elsif taxable_net_income <= 100_000
                         0.0275
                       elsif taxable_net_income <= 250_000
                         0.0296
                       else
                         0.032
                       end
                     end
                   end

        tax_rate&.to_d
      end

      def local_tax_rate
        @lines[:MD502_LINE_28_LOCAL_TAX_RATE]&.value || 0
      end

      def calculate_line_28_local_tax_amount
        taxable_net_income = line_or_zero(:MD502_LINE_20)

        if @intake.residence_county == "Anne Arundel"
          brackets = if filing_status_dependent? || filing_status_single? || filing_status_mfs?
                       [
                         { threshold: 50_000, rate: 0.0270 },
                         { threshold: 400_000, rate: 0.0281 },
                         { threshold: Float::INFINITY, rate: 0.0320 }
                       ]
                     elsif filing_status_mfj? || filing_status_hoh? || filing_status_qw?
                       [
                         { threshold: 75_000, rate: 0.0270 },
                         { threshold: 480_000, rate: 0.0281 },
                         { threshold: Float::INFINITY, rate: 0.0320 }
                       ]
                     end

          tax = 0
          previous_threshold = 0

          brackets.each do |bracket|
            if taxable_net_income > previous_threshold
              income_in_bracket = [taxable_net_income, bracket[:threshold]].min - previous_threshold
              tax += income_in_bracket * bracket[:rate].to_d
              previous_threshold = bracket[:threshold]
            else
              break
            end
          end

          tax.round
        else
          (local_tax_rate * taxable_net_income).round
        end
      end

      def calculate_line_29
        (@direct_file_data.fed_eic * (local_tax_rate * 10)).round
      end

      def calculate_line_30
        if deduction_method_is_standard? && line_or_zero(:MD502_LINE_23).positive?
          (line_or_zero(:MD502_LINE_1B) * local_tax_rate).round
        end
      end

      def calculate_line_32
        if deduction_method_is_standard?
          line_or_zero(:MD502_LINE_29) + line_or_zero(:MD502_LINE_30)
        end
      end

      def calculate_line_33
        if deduction_method_is_standard?
          [(line_or_zero(:MD502_LINE_28_LOCAL_TAX_AMOUNT) - line_or_zero(:MD502_LINE_32)), 0].max
        end
      end

      def calculate_line_34
        if deduction_method_is_standard?
          line_or_zero(:MD502_LINE_27) + line_or_zero(:MD502_LINE_33)
        end
      end

      def calculate_line_39
        (34..38).sum do |line_num|
          line_or_zero("MD502_LINE_#{line_num}")
        end
      end

      def calculate_line_40
        @intake.state_file_w2s.sum { |item| item.state_income_tax_amount.round } +
          @intake.state_file_w2s.sum { |item| item.local_income_tax_amount.round } +
          @intake.state_file1099_gs.sum { |item| item.state_income_tax_withheld_amount.round } +
          @intake.state_file1099_rs.sum { |item| item.state_tax_withheld_amount.round }
      end

      def calculate_line_42
        # Earned Income Credit (EIC)
        if filing_status_mfj? || filing_status_mfs? || @direct_file_data.fed_eic_qc_claimed
          [(@direct_file_data.fed_eic * 0.45).round - line_or_zero(:MD502_LINE_21), 0].max
        elsif filing_status_single? || filing_status_hoh? || filing_status_qw?
          [@direct_file_data.fed_eic - line_or_zero(:MD502_LINE_21), 0].max
        end
      end

      def calculate_line_43
        line_or_zero(:MD502CR_PART_CC_LINE_10)
      end

      def calculate_line_44
        [40, 42, 43].sum { |number| line_or_zero("MD502_LINE_#{number}") }
      end

      def calculate_line_45
        if line_or_zero(:MD502_LINE_39) > line_or_zero(:MD502_LINE_44)
          line_or_zero(:MD502_LINE_39) - line_or_zero(:MD502_LINE_44)
        end
      end

      def calculate_line_46
        if line_or_zero(:MD502_LINE_39) < line_or_zero(:MD502_LINE_44)
          line_or_zero(:MD502_LINE_44) - line_or_zero(:MD502_LINE_39)
        end
      end

      def calculate_line_48
        line_or_zero(:MD502_LINE_46) - line_or_zero(:MD502_LINE_47)
      end

      def calculate_line_50
        line_or_zero(:MD502_LINE_45) + line_or_zero(:MD502_LINE_49)
      end

      def filing_status_dependent?
        @filing_status == :dependent
      end

      def deduction_method_is_standard?
        @lines[:MD502_DEDUCTION_METHOD]&.value == "S"
      end
    end
  end
end
