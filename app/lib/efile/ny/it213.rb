module Efile
  module Ny
    class It213 < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, filing_status:, direct_file_data:, eligibility_lived_in_state:, federal_dependent_child_count:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @filing_status = filing_status
        @direct_file_data = direct_file_data
        @eligibility_lived_in_state = eligibility_lived_in_state
        @federal_dependent_child_count = federal_dependent_child_count
      end

      def calculate
        set_line(:IT213_LINE_1, -> { @eligibility_lived_in_state })
        # If line 1 is false, stop, you do not qualify for the credit
        if @eligibility_lived_in_state
          set_line(:IT213_LINE_2, -> { @direct_file_data.fed_ctc_claimed })
          set_line(:IT213_LINE_3, :calculate_line_3)
          # If lines 2 and 3 are false, stop, you do not qualify for this credit
          if @lines[:IT213_LINE_2].value == true || @lines[:IT213_LINE_3].value == true
            set_line(:IT213_LINE_4, -> { @federal_dependent_child_count})
            set_line(:IT213_LINE_5, -> { 0 }) # TODO: double check that people with children without SSN/ITIN are out of scope
            # If line 2 is true, you must complete Worksheet A and B before you continue with line 6.
            # If line 2 is false, skip lines 6 through 8, and enter 0 on line 9; continue with line 10.
            if @lines[:IT213_LINE_2].value == true
              calculate_worksheets
            else
              set_line(:IT213_LINE_9, -> { 0 })
            end
            # If line 3 is false, skip lines 10 through 13, and enter the amount from line 9 on line 14.
            # All others continue with line 10.
            if @lines[:IT213_LINE_3].value == true
              set_line(:IT213_LINE_10, :calculate_line_10)
              set_line(:IT213_LINE_11, :calculate_line_11)
              set_line(:IT213_LINE_12, :calculate_line_12)
              set_line(:IT213_LINE_13, :calculate_line_13)
              set_line(:IT213_LINE_14, :calculate_line_14)
            else
              set_line(:IT213_LINE_14, -> { @lines[:IT213_LINE_9].value })
            end
            # TODO: if spouse filing separate, lines 15 and 16 could have share of credit for spouse
            set_line(:IT213_LINE_15, -> { 0 })
            set_line(:IT213_LINE_16, -> { 0 })
          else
            offboard
            return
          end
        else
          offboard
        end
      end

      private

      def calculate_worksheets
        set_line(:IT213_WORKSHEET_A_LINE_1, :calculate_worksheet_a_line_1)
        set_line(:IT213_WORKSHEET_A_LINE_2, :calculate_worksheet_a_line_2)
        set_line(:IT213_WORKSHEET_A_LINE_3, :calculate_worksheet_a_line_3)
        set_line(:IT213_WORKSHEET_A_LINE_4, :calculate_worksheet_a_line_4)
        set_line(:IT213_WORKSHEET_A_LINE_5, :calculate_worksheet_a_line_5)
        set_line(:IT213_WORKSHEET_A_LINE_6, :calculate_worksheet_a_line_6)
        set_line(:IT213_WORKSHEET_A_LINE_7, :calculate_worksheet_a_line_7)
        set_line(:IT213_WORKSHEET_A_LINE_8, :calculate_worksheet_a_line_8)
        # Is line 8 positive?
        # If Yes, Subtract line 7 from line 1. Enter the result and complete Part 2.
        # If No, Enter 0 on Form IT-213, line 6 and 0 on Form IT-213, line 7.
        if @lines[:IT213_WORKSHEET_A_LINE_8].value.positive?
          set_line(:IT213_WORKSHEET_A_LINE_9, :calculate_worksheet_a_line_9)
          set_line(:IT213_WORKSHEET_A_LINE_10, :calculate_worksheet_a_line_10)
          set_line(:IT213_WORKSHEET_A_LINE_11, :calculate_worksheet_a_line_11)
          set_line(:IT213_WORKSHEET_A_LINE_12, :calculate_worksheet_a_line_12)
          # Is the amount on line 8 of this worksheet more than the amount on line 12?
          # If No: Stop here. Enter the amount from line 8 here and on Form IT-213, line 6; and enter 0 on Form IT-213, line 7.
          # If Yes: Enter the amount from line 12 here and on Form IT-213, line 6; and complete Worksheet B: Additional child tax credit amount.
          set_line(:IT213_WORKSHEET_A_LINE_13, :calculate_worksheet_a_line_13)
          if @lines[:IT213_WORKSHEET_A_LINE_8].value > @lines[:IT213_WORKSHEET_A_LINE_12].value
            set_line(:IT213_LINE_6, -> { @lines[:IT213_WORKSHEET_A_LINE_12].value.to_i })
            set_line(:IT213_WORKSHEET_B_LINE_1, :calculate_worksheet_b_line_1)
            set_line(:IT213_WORKSHEET_B_LINE_2, :calculate_worksheet_b_line_2)
            # If the amount on line 2 is greater than or equal to the amount on line 1, stop here; you do not qualify for the additional child credit. Enter 0 on Form IT-213, line 7.
            # If the amount on line 2 is less than the amount on line 1, go to line 3.
            if @lines[:IT213_WORKSHEET_B_LINE_2].value >= @lines[:IT213_WORKSHEET_B_LINE_1].value
              set_line(:IT213_LINE_7, -> { 0 })
            else
              set_line(:IT213_WORKSHEET_B_LINE_3, :calculate_worksheet_b_line_3)
              set_line(:IT213_WORKSHEET_B_LINE_4A, @direct_file_data.fed_total_earned_income_amount)
              set_line(:IT213_WORKSHEET_B_LINE_4B, @direct_file_data.fed_nontaxable_combat_pay_amount)
              set_line(:IT213_WORKSHEET_B_LINE_5, :calculate_worksheet_b_line_5)
              set_line(:IT213_WORKSHEET_B_LINE_6, :calculate_worksheet_b_line_6)
              # Do you have three or more children (from Form IT-213, line 4)?
              # If No: Stop here and enter the smaller of lines 3 or 6 on Form IT-213, line 7.
              # If Yes:
              #   If line 6 is equal to or more than line 3, stop here and enter the amount from line 3 on Form IT-213, line 7.
              #   If line 6 is less than line 3, enter the amount from your federal Schedule 8812, line 25 here and continue with line 8.
              if @lines[:IT213_LINE_4].value >= 3
                if @lines[:IT213_WORKSHEET_B_LINE_6].value >= @lines[:IT213_WORKSHEET_B_LINE_3].value
                  set_line(:IT213_LINE_7, -> { @lines[:IT213_WORKSHEET_B_LINE_3].value.to_i })
                else
                  set_line(:IT213_WORKSHEET_B_LINE_7, @direct_file_data.fed_calculated_difference_amount)
                  set_line(:IT213_WORKSHEET_B_LINE_8, :calculate_worksheet_b_line_8)
                  set_line(:IT213_WORKSHEET_B_LINE_9, :calculate_worksheet_b_line_9)
                  set_line(:IT213_LINE_7, -> { @lines[:IT213_WORKSHEET_B_LINE_9].value.to_i })
                end
              else
                set_line(:IT213_LINE_7, -> { [@lines[:IT213_WORKSHEET_B_LINE_3].value, @lines[:IT213_WORKSHEET_B_LINE_6].value].min.to_i })
              end
            end
          else
            set_line(:IT213_LINE_6, -> { @lines[:IT213_WORKSHEET_A_LINE_8].value.to_i })
            set_line(:IT213_LINE_7, -> { 0 })
          end
        else
          set_line(:IT213_LINE_6, -> { 0 })
          set_line(:IT213_LINE_7, -> { 0 })
        end
        set_line(:IT213_LINE_8, :calculate_line_8)
        set_line(:IT213_LINE_9, :calculate_line_9)
      end

      def calculate_line_3
        @lines[:IT201_LINE_19].value <= cutoff_for_filing_status
      end

      def calculate_worksheet_a_line_1
        @federal_dependent_child_count * 1000
      end

      def calculate_worksheet_a_line_2
        @lines[:IT201_LINE_19].value
      end

      def calculate_worksheet_a_line_3
        # 2023 instructions:
        # 0 if you filed federal Form 1040NR
        # OR
        # fed form 2555 line 45 TotalIncomeExclusionAmt + fed form 2555 line 50 HousingDeductionAmt +
        # fed form 4563 line 15 GrossIncomeExclusionAmt + fed section 933 Exclusion of income from Puerto Rico
        return 0 if @direct_file_data.fed_irs_1040_nr_filed
        @direct_file_data.fed_total_income_exclusion_amount + @direct_file_data.fed_housing_deduction_amount +
          @direct_file_data.fed_gross_income_exclusion_amount + @direct_file_data.fed_puerto_rico_income_exclusion_amount
      end

      def calculate_worksheet_a_line_4
        line_or_zero(:IT213_WORKSHEET_A_LINE_2) + line_or_zero(:IT213_WORKSHEET_A_LINE_3)
      end

      def calculate_worksheet_a_line_5
        cutoff_for_filing_status
      end

      def calculate_worksheet_a_line_6
        if @lines[:IT213_WORKSHEET_A_LINE_4].value > @lines[:IT213_WORKSHEET_A_LINE_5].value
          subtotal = @lines[:IT213_WORKSHEET_A_LINE_4].value - @lines[:IT213_WORKSHEET_A_LINE_5].value
          subtotal.ceil(-3) # Round up to next 1000
        end
      end

      def calculate_worksheet_a_line_7
        line_or_zero(:IT213_WORKSHEET_A_LINE_6) * 0.05
      end

      def calculate_worksheet_a_line_8
        [@lines[:IT213_WORKSHEET_A_LINE_1].value - @lines[:IT213_WORKSHEET_A_LINE_7].value, 0].max
      end

      def calculate_worksheet_a_line_9
        @direct_file_data.fed_tax
      end

      def calculate_worksheet_a_line_10
        0 # TODO: check if we always set schedule 3 credits to 0
      end

      def calculate_worksheet_a_line_11
        # If any of these credits are > 0 then we need to do some more calculations, otherwise return value of
        # worksheet a line 10
        #   Mortgage interest credit (federal Form 8396)
        #   Adoption credit (federal Form 8839)
        #   Residential clean energy credit (federal Form 5695, Part 1)
        #   District of Columbia first-time homebuyer credit (federal Form 8859)

        # TODO: implement worksheet for line 100 of worksheet A (!!)
        # total_credits = @direct_file_data.fed_mortgage_interest_credit_amount +
        #                 @direct_file_data.fed_adoption_credit_amount +
        #                 @direct_file_data.fed_residential_clean_energy_credit_amount +
        #                 @direct_file_data.fed_dc_homebuyer_credit_amount

        # if total_credits > 0
        # end
        @lines[:IT213_WORKSHEET_A_LINE_10].value
      end

      def calculate_worksheet_a_line_12
        [@lines[:IT213_WORKSHEET_A_LINE_9].value - @lines[:IT213_WORKSHEET_A_LINE_11].value, 0].max
      end

      def calculate_worksheet_a_line_13
        [@lines[:IT213_WORKSHEET_A_LINE_8].value, @lines[:IT213_WORKSHEET_A_LINE_12].value].min
      end

      def calculate_worksheet_b_line_1
        @lines[:IT213_WORKSHEET_A_LINE_8].value
      end

      def calculate_worksheet_b_line_2
        @lines[:IT213_LINE_6].value
      end

      def calculate_worksheet_b_line_3
        @lines[:IT213_WORKSHEET_B_LINE_1].value - @lines[:IT213_WORKSHEET_B_LINE_2].value
      end

      def calculate_worksheet_b_line_5
        [@lines[:IT213_WORKSHEET_B_LINE_4A].value - 3000, 0].max
      end

      def calculate_worksheet_b_line_6
        line_or_zero(:IT213_WORKSHEET_B_LINE_5) * 0.15
      end

      def calculate_worksheet_b_line_8
        [@lines[:IT213_WORKSHEET_B_LINE_6].value, @lines[:IT213_WORKSHEET_B_LINE_7].value].max
      end

      def calculate_worksheet_b_line_9
        [@lines[:IT213_WORKSHEET_B_LINE_3].value, @lines[:IT213_WORKSHEET_B_LINE_8].value].min
      end

      def calculate_line_8
        line_or_zero(:IT213_LINE_6) + line_or_zero(:IT213_LINE_7)
      end

      def calculate_line_9
        (line_or_zero(:IT213_LINE_8) * 0.33).to_i
      end

      def calculate_line_10
        line_or_zero(:IT213_LINE_4)
      end

      def calculate_line_11
        line_or_zero(:IT213_LINE_5)
      end

      def calculate_line_12
        line_or_zero(:IT213_LINE_10) + line_or_zero(:IT213_LINE_11)
      end

      def calculate_line_13
        line_or_zero(:IT213_LINE_12) * 100
      end

      def calculate_line_14
        [line_or_zero(:IT213_LINE_9), line_or_zero(:IT213_LINE_13)].max
      end

      def offboard
        set_line(:IT213_LINE_14, -> { 0 })
      end

      def cutoff_for_filing_status
        case @filing_status
        when :married_filing_jointly
          110_000
        when :single, :head_of_household, :qualifying_surviving_spouse
          75_000
        when :married_filing_separately
          55_000
        else
          raise "Filing status not found..."
        end
      end
    end
  end
end
