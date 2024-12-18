module Efile
  module Id
    class Id40Calculator < ::Efile::TaxCalculator
      attr_reader :lines
      set_refund_owed_lines refund: :ID40_LINE_56, owed: :ID40_LINE_54

      def initialize(year:, intake:, include_source: false)
        super
        @id39r = Efile::Id::Id39RCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake,
        )
      end

      def calculate
        @id39r.calculate
        set_line(:ID40_LINE_6A, :calculate_line_6a)
        set_line(:ID40_LINE_6B, :calculate_line_6b)
        set_line(:ID40_LINE_6C, :calculate_line_6c)
        set_line(:ID40_LINE_6D, :calculate_line_6d)
        set_line(:ID40_LINE_7, :calculate_line_7)
        set_line(:ID40_LINE_8, :calculate_line_8)
        set_line(:ID40_LINE_9, :calculate_line_9)
        set_line(:ID40_LINE_10, :calculate_line_10)
        set_line(:ID40_LINE_11, :calculate_line_11)
        set_line(:ID40_LINE_16, :calculate_line_16)
        set_line(:ID40_LINE_19, :calculate_line_19)
        set_line(:ID40_LINE_20, :calculate_line_20)
        set_line(:ID40_LINE_21, :calculate_line_20)
        set_line(:ID40_LINE_23, :calculate_line_23)
        set_line(:ID40_LINE_25, :calculate_line_25)
        set_line(:ID40_LINE_26, :calculate_line_26)
        set_line(:ID40_LINE_27, :calculate_line_27)
        set_line(:ID40_LINE_29, :calculate_line_29)
        set_line(:ID40_LINE_32A, :calculate_line_32a)
        set_line(:ID40_LINE_32B, :calculate_line_32b)
        set_line(:ID40_LINE_33, :calculate_line_33)
        set_line(:ID40_LINE_34, :calculate_line_34)
        set_line(:ID40_LINE_35, :calculate_line_35)
        set_line(:ID40_LINE_36, :calculate_line_36)
        set_line(:ID40_LINE_37, :calculate_line_37)
        set_line(:ID40_LINE_38, :calculate_line_38)
        set_line(:ID40_LINE_39, :calculate_line_39)
        set_line(:ID40_LINE_40, :calculate_line_40)
        set_line(:ID40_LINE_41, :calculate_line_41)
        set_line(:ID40_LINE_42, :calculate_line_42)
        set_line(:ID40_LINE_43_WORKSHEET, :calculate_grocery_credit)
        set_line(:ID40_LINE_43_DONATE, :calculate_line_43_donate)
        set_line(:ID40_LINE_43, :calculate_line_43)
        set_line(:ID40_LINE_46, :calculate_line_46)
        set_line(:ID40_LINE_50, :calculate_line_50)
        set_line(:ID40_LINE_51, :calculate_line_51)
        set_line(:ID40_LINE_54, :calculate_line_54)
        set_line(:ID40_LINE_55, :calculate_line_55)
        set_line(:ID40_LINE_56, :calculate_line_56)
        @lines.transform_values(&:value)
      end

      def grocery_credit_amount
        line_or_zero(:ID40_LINE_43_WORKSHEET)
      end

      def analytics_attrs
        {}
      end

      private

      def calculate_line_6a
        @direct_file_data.claimed_as_dependent? ? 0 : 1
      end

      def calculate_line_6b
        (@intake.filing_status_mfj? && !@direct_file_data.spouse_is_a_dependent?) ? 1 : 0
      end

      def calculate_line_6c
        @intake.dependents.count
      end

      def calculate_line_6d
        line_or_zero(:ID40_LINE_6A) + line_or_zero(:ID40_LINE_6B) + line_or_zero(:ID40_LINE_6C)
      end

      def calculate_line_7
        @direct_file_data.fed_agi
      end

      def calculate_line_8
        line_or_zero(:ID39R_A_LINE_7)
      end

      def calculate_line_9
        line_or_zero(:ID40_LINE_7) + line_or_zero(:ID40_LINE_8)
      end

      def calculate_line_10
        line_or_zero(:ID39R_B_LINE_24)
      end

      def calculate_line_11
        [line_or_zero(:ID40_LINE_9) - line_or_zero(:ID40_LINE_10), 0].max
      end

      def calculate_line_16
        @direct_file_data.total_itemized_or_standard_deduction_amount
      end

      # Subtract the larger of L15 or L16 from L11 but L15 is always 0
      # L16 is pulled from df data
      def calculate_line_19
        [line_or_zero(:ID40_LINE_11) - line_or_zero(:ID40_LINE_16), 0].max
      end

      WK_LINE_2_AMTS = {
        single: 4673,
        married_filing_separately: 4673,
        married_filing_jointly: 9346,
        head_of_household: 9346,
        qualifying_widow: 9346,
      }.freeze
      def calculate_line_20
        worksheet_line_2_amount = WK_LINE_2_AMTS[@filing_status]
        [((line_or_zero(:ID40_LINE_19) - worksheet_line_2_amount) * 0.05695).round, 0].max
      end

      def calculate_line_23
        line_or_zero(:ID39R_D_LINE_4)
      end

      def calculate_line_25
        wrksht_line_1 = @intake.dependents.count do |dependent|
          dependent.qualifying_child? && dependent.under_17?
        end

        return 0 if wrksht_line_1.zero?

        wrksht_line_2 = 205 * wrksht_line_1
        total_credit = [line_or_zero(:ID40_LINE_22), line_or_zero(:ID40_LINE_23), line_or_zero(:ID40_LINE_24)].sum
        wrksht_line_7 = [line_or_zero(:ID40_LINE_20) - total_credit, 0].max

        [wrksht_line_2, wrksht_line_7].min
      end

      def calculate_line_26
        line_or_zero(:ID40_LINE_23) + line_or_zero(:ID40_LINE_25)
      end

      def calculate_line_27
        [line_or_zero(:ID40_LINE_21) - line_or_zero(:ID40_LINE_26), 0].max
      end

      def calculate_line_29
        if @intake.has_unpaid_sales_use_tax? && !@intake.total_purchase_amount.nil?
          (@intake.total_purchase_amount * 0.06).round
        else
          0
        end
      end

      def calculate_line_32a
        if @intake.has_filing_requirement? && !@intake.has_blind_filer? && @intake.received_id_public_assistance_no?
          10
        else
          0
        end
      end

      def calculate_line_32b
        @intake.received_id_public_assistance_yes?
      end

      def calculate_line_33
        line_or_zero(:ID40_LINE_27) + line_or_zero(:ID40_LINE_29) + line_or_zero(:ID40_LINE_32A)
      end

      def calculate_line_34
        @intake.nongame_wildlife_fund_donation
      end

      def calculate_line_35
        @intake.childrens_trust_fund_donation
      end

      def calculate_line_36
        @intake.special_olympics_donation
      end

      def calculate_line_37
        @intake.guard_reserve_family_donation
      end

      def calculate_line_38
        @intake.american_red_cross_fund_donation
      end

      def calculate_line_39
        @intake.veterans_support_fund_donation
      end

      def calculate_line_40
        @intake.food_bank_fund_donation
      end

      def calculate_line_41
        @intake.opportunity_scholarship_program_donation
      end

      def calculate_line_42
        lines = %i[ID40_LINE_33 ID40_LINE_34 ID40_LINE_35 ID40_LINE_36 ID40_LINE_37 ID40_LINE_38 ID40_LINE_39 ID40_LINE_40 ID40_LINE_41]
        lines.sum { |line| line_or_zero(line) }
      end

      def calculate_grocery_credit
        return 0 if @direct_file_data.claimed_as_dependent?

        credit = 0

        primary_eligible_months = 12
        if @intake.household_has_grocery_credit_ineligible_months_yes? && @intake.primary_has_grocery_credit_ineligible_months_yes?
          primary_eligible_months -= @intake.primary_months_ineligible_for_grocery_credit
        end
        credit += primary_eligible_months * (@intake.primary_senior? ? 11.67 : 10)

        if filing_status_mfj?
          spouse_eligible_months = 12
          if @intake.household_has_grocery_credit_ineligible_months_yes? && @intake.spouse_has_grocery_credit_ineligible_months_yes?
            spouse_eligible_months -= @intake.spouse_months_ineligible_for_grocery_credit
          end
          credit += spouse_eligible_months * (@intake.spouse_senior? ? 11.67 : 10)
        end

        @intake.dependents.each do |dependent|
          dependent_eligible_months = 12
          if @intake.household_has_grocery_credit_ineligible_months_yes? && dependent.id_has_grocery_credit_ineligible_months_yes?
            dependent_eligible_months -= dependent.id_months_ineligible_for_grocery_credit
          end
          credit += dependent_eligible_months * 10
        end

        credit.round
      end

      def calculate_line_43_donate
        @intake.donate_grocery_credit_yes?
      end

      def calculate_line_43
        @lines[:ID40_LINE_43_DONATE]&.value ? 0 : line_or_zero(:ID40_LINE_43_WORKSHEET)
      end

      def calculate_line_46
        @intake.state_file_w2s.sum { |item| item.state_income_tax_amount.round } +
          @intake.state_file1099_gs.sum { |item| item.state_income_tax_withheld_amount.round } +
          @intake.state_file1099_rs.sum { |item| item.state_tax_withheld_amount.round }
      end

      def calculate_line_50
        line_or_zero(:ID40_LINE_43) + line_or_zero(:ID40_LINE_46)
      end

      def calculate_line_51
        if line_or_zero(:ID40_LINE_42) > line_or_zero(:ID40_LINE_50)
          line_or_zero(:ID40_LINE_42) - line_or_zero(:ID40_LINE_50)
        end
      end

      def calculate_line_54
        line_or_zero(:ID40_LINE_51)
      end

      def calculate_line_55
        if line_or_zero(:ID40_LINE_42) < line_or_zero(:ID40_LINE_50)
          line_or_zero(:ID40_LINE_50) - line_or_zero(:ID40_LINE_42)
        end
      end

      def calculate_line_56
        line_or_zero(:ID40_LINE_55)
      end
    end
  end
end
