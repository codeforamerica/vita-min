module Efile
  module Nj
    class Nj1040Calculator < ::Efile::TaxCalculator
      attr_reader :lines
      set_refund_owed_lines refund: :NJ1040_LINE_80, owed: :NJ1040_LINE_79

      RENT_CONVERSION = 0.18
      MAX_NJ_CTC_DEPENDENTS = 9

      def initialize(year:, intake:, include_source: false)
        super
        @nj2450_primary = Efile::Nj::Nj2450Calculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake,
          primary_or_spouse: :primary
        )
        @nj2450_spouse = Efile::Nj::Nj2450Calculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake,
          primary_or_spouse: :spouse
        )
        @nj_retirement_income_helper = Efile::Nj::NjRetirementIncomeHelper.new(@intake)
      end

      def calculate
        set_line(:NJ1040_LINE_6_SPOUSE, :line_6_spouse_checkbox)
        set_line(:NJ1040_LINE_7_SELF, :line_7_self_checkbox)
        set_line(:NJ1040_LINE_7_SPOUSE, :line_7_spouse_checkbox)
        set_line(:NJ1040_LINE_8_SELF, :line_8_self_checkbox)
        set_line(:NJ1040_LINE_8_SPOUSE, :line_8_spouse_checkbox)
        set_line(:NJ1040_LINE_10_COUNT, :calculate_line_10_count)
        set_line(:NJ1040_LINE_10_EXEMPTION, :calculate_line_10_exemption)
        set_line(:NJ1040_LINE_11_COUNT, :calculate_line_11_count)
        set_line(:NJ1040_LINE_11_EXEMPTION, :calculate_line_11_exemption)
        set_line(:NJ1040_LINE_12_COUNT, :line_12_count)
        set_line(:NJ1040_LINE_13, :calculate_line_13)
        set_line(:NJ1040_LINE_15, :calculate_line_15)
        set_line(:NJ1040_LINE_16A, :calculate_line_16a)
        set_line(:NJ1040_LINE_16B, :calculate_line_16b)
        set_line(:NJ1040_LINE_20A, :calculate_line_20a)
        set_line(:NJ1040_LINE_20B, :calculate_line_20b)
        set_line(:NJ1040_LINE_27, :calculate_line_27)
        set_line(:NJ1040_LINE_28A, :calculate_line_28a)
        set_line(:NJ1040_LINE_28B, :calculate_line_28b)
        set_line(:NJ1040_LINE_28C, :calculate_line_28c)
        set_line(:NJ1040_LINE_29, :calculate_line_29)
        set_line(:NJ1040_LINE_31, :calculate_line_31)
        set_line(:NJ1040_LINE_38, :calculate_line_38)
        set_line(:NJ1040_LINE_39, :calculate_line_39)
        set_line(:NJ1040_LINE_40A, :calculate_line_40a)
        set_line(:NJ1040_LINE_41, :calculate_line_41)
        set_line(:NJ1040_LINE_42, :calculate_line_42)
        set_line(:NJ1040_LINE_43, :calculate_line_43)
        set_line(:NJ1040_LINE_45, :calculate_line_45)
        set_line(:NJ1040_LINE_49, :calculate_line_49)
        set_line(:NJ1040_LINE_50, :calculate_line_50)
        set_line(:NJ1040_LINE_51, :calculate_line_51)
        set_line(:NJ1040_LINE_53C_CHECKBOX, :line_53c_checkbox)
        set_line(:NJ1040_LINE_54, :calculate_line_54)
        set_line(:NJ1040_LINE_55, :calculate_line_55)
        set_line(:NJ1040_LINE_56, :calculate_line_56)
        set_line(:NJ1040_LINE_57, :calculate_line_57)
        set_line(:NJ1040_LINE_58, :calculate_line_58)
        set_line(:NJ1040_LINE_58_IRS, :calculate_line_58_irs)
        set_line(:NJ1040_LINE_59, :calculate_line_59)
        set_line(:NJ1040_LINE_60, :calculate_line_60)
        set_line(:NJ1040_LINE_61, :calculate_line_61)
        set_line(:NJ1040_LINE_62, :calculate_line_62)
        set_line(:NJ1040_LINE_63, :calculate_line_63)
        set_line(:NJ1040_LINE_64, :calculate_line_64)
        set_line(:NJ1040_LINE_65_DEPENDENTS, :number_of_dependents_age_5_younger)
        set_line(:NJ1040_LINE_65, :calculate_line_65)
        set_line(:NJ1040_LINE_66, :calculate_line_66)
        set_line(:NJ1040_LINE_67, :calculate_line_67)
        set_line(:NJ1040_LINE_68, :calculate_line_68)
        set_line(:NJ1040_LINE_69, :calculate_line_69)
        set_line(:NJ1040_LINE_70, :calculate_line_70)
        set_line(:NJ1040_LINE_71, :calculate_line_71)
        set_line(:NJ1040_LINE_72, :calculate_line_72)
        set_line(:NJ1040_LINE_73, :calculate_line_73)
        set_line(:NJ1040_LINE_74, :calculate_line_74)
        set_line(:NJ1040_LINE_75, :calculate_line_75)
        set_line(:NJ1040_LINE_76, :calculate_line_76)
        set_line(:NJ1040_LINE_77, :calculate_line_77)
        set_line(:NJ1040_LINE_78, :calculate_line_78)
        set_line(:NJ1040_LINE_79, :calculate_line_79)
        set_line(:NJ1040_LINE_79_CHECKBOX, :calculate_line_79_checkbox)
        set_line(:NJ1040_LINE_80, :calculate_line_80)
        @nj2450_primary.calculate if line_59_primary || line_61_primary
        @nj2450_spouse.calculate if line_59_spouse || line_61_spouse
        @lines.transform_values(&:value)
      end

      def analytics_attrs
        {}
      end

      def get_tax_rate_and_subtraction_amount(income)
        if @intake.filing_status_mfs? || @intake.filing_status_single?
          case income
          when 1..20_000
            [0.014, 0]
          when 20_000..35_000
            [0.0175, 70.00]
          when 35_000..40_000
            [0.035, 682.50]
          when 40_000..75_000
            [0.05525, 1_492.50]
          when 75_000..500_000
            [0.0637, 2_126.25]
          when 500_000..1_000_000
            [0.0897, 15_126.25]
          when 1_000_000..Float::INFINITY
            [0.1075, 32_926.25]
          else
            [0, 0]
          end
        else
          case income
          when 1..20_000
            [0.014, 0]
          when 20_000..50_000
            [0.0175, 70.00]
          when 50_000..70_000
            [0.0245, 420.00]
          when 70_000..80_000
            [0.035, 1_154.50]
          when 80_000..150_000
            [0.05525, 2_775.00]
          when 150_000..500_000
            [0.0637, 4_042.50]
          when 500_000..1_000_000
            [0.0897, 17_042.50]
          when 1_000_000..Float::INFINITY
            [0.1075, 34_842.50]
          else
            [0, 0]
          end
        end
      end

      def calculate_property_tax_deduction
        limit = is_mfs_same_home ? 7_500 : 15_000
        if @lines[:NJ1040_LINE_40A]&.value.nil?
          return nil
        end

        [line_or_zero(:NJ1040_LINE_40A), limit].min
      end

      def calculate_tax_liability_with_deduction
        return nil if calculate_property_tax_deduction.nil?
        income = line_or_zero(:NJ1040_LINE_39) - calculate_property_tax_deduction
        (rate, subtraction) = get_tax_rate_and_subtraction_amount(income)
        ((income * rate) - subtraction).round(2)
      end

      def calculate_tax_liability_without_deduction
        income = line_or_zero(:NJ1040_LINE_39)
        (rate, subtraction) = get_tax_rate_and_subtraction_amount(income)
        ((income * rate) - subtraction).round(2)
      end

      def should_use_property_tax_deduction
        return false if calculate_tax_liability_with_deduction.nil?
        calculate_tax_liability_without_deduction - calculate_tax_liability_with_deduction >= 50
      end

      def calculate_use_tax(nj_gross_income)
        case nj_gross_income
        when -Float::INFINITY..15_000
          14
        when 15_000..30_000
          44
        when 30_000..50_000
          64
        when 50_000..75_000
          84
        when 75_000..100_000
          106
        when 100_000..150_000
          134
        when 150_000..200_000
          170
        when 200_000..Float::INFINITY
          [0.000852 * nj_gross_income, 494].min.round
        end
      end

      def calculate_tax_exempt_interest_income
        @intake.direct_file_data.fed_tax_exempt_interest + interest_on_gov_bonds
      end

      def calculate_line_6
        self_exemption = 1
        number_of_line_6_exemptions = self_exemption + number_of_true_checkboxes([line_6_spouse_checkbox])
        number_of_line_6_exemptions * 1_000
      end

      def line_7_self_checkbox
        @intake.primary_senior?
      end

      def line_7_spouse_checkbox
        @intake.spouse_senior?
      end

      def line_12_count
        @intake.dependents.count(&:nj_qualifies_for_college_exemption?)
      end

      def calculate_line_7
        number_of_line_7_exemptions = number_of_true_checkboxes([line_7_self_checkbox,
                                                                 line_7_spouse_checkbox])
        number_of_line_7_exemptions * 1_000
      end

      def calculate_line_8
        number_of_line_8_exemptions = number_of_true_checkboxes([line_8_self_checkbox,
                                                                 line_8_spouse_checkbox])
        number_of_line_8_exemptions * 1_000
      end

      def calculate_line_9
        number_of_line_9_exemptions = number_of_true_checkboxes([@intake.primary_veteran_yes?, @intake.spouse_veteran_yes?])
        number_of_line_9_exemptions * 6_000
      end

      def calculate_line_10_count
        @intake.dependents.count(&:qualifying_child)
      end

      def calculate_line_10_exemption
        line_or_zero(:NJ1040_LINE_10_COUNT) * 1500
      end

      def calculate_line_11_count
        @intake.dependents.count do |dependent|
          !dependent.qualifying_child
        end
      end

      def calculate_line_11_exemption
        line_or_zero(:NJ1040_LINE_11_COUNT) * 1500
      end

      def calculate_line_12
        line_or_zero(:NJ1040_LINE_12_COUNT) * 1_000
      end

      def line_53c_checkbox
        @intake.eligibility_all_members_health_insurance_yes?
      end

      def line_59_primary
        get_personal_excess(@intake.primary.ssn, ->(w2) { w2.get_box14_ui_overwrite }, excess_ui_wf_swf_max)
      end

      def line_59_spouse
        if @intake.filing_status_mfj?
          get_personal_excess(@intake.spouse.ssn, ->(w2) { w2.get_box14_ui_overwrite }, excess_ui_wf_swf_max)
        end
      end

      def line_61_primary
        get_personal_excess(@intake.primary.ssn, ->(w2) { w2[:box14_fli] }, excess_fli_max)
      end

      def line_61_spouse
        if @intake.filing_status_mfj?
          get_personal_excess(@intake.spouse.ssn, ->(w2) { w2[:box14_fli] }, excess_fli_max)
        end
      end

      def excess_ui_wf_swf_max
        @excess_ui_wf_swf_max ||= StateFileW2.find_limit("UI_WF_SWF", "nj")
      end

      def excess_fli_max
        @excess_fli_max ||= StateFileW2.find_limit("FLI", "nj")
      end

      private

      def line_6_spouse_checkbox
        @intake.filing_status_mfj?
      end

      def line_8_self_checkbox
        @direct_file_data.is_primary_blind? || @intake.primary_disabled_yes?
      end

      def line_8_spouse_checkbox
        @direct_file_data.is_spouse_blind? || @intake.spouse_disabled_yes?
      end

      def calculate_line_13
        calculate_line_6 +
          calculate_line_7 +
          calculate_line_8 +
          calculate_line_9 +
          line_or_zero(:NJ1040_LINE_10_EXEMPTION) +
          line_or_zero(:NJ1040_LINE_11_EXEMPTION) +
          calculate_line_12
      end

      def calculate_line_15
        @intake.state_file_w2s.sum(&:state_wages_amount).round
      end

      def calculate_line_16a
        @intake.direct_file_data.fed_taxable_income - interest_on_gov_bonds
      end

      def calculate_line_16b
        calculate_tax_exempt_interest_income if calculate_tax_exempt_interest_income.positive?
      end

      def calculate_line_20a
        non_military_1099rs.sum(&:taxable_amount).round
      end

      def calculate_line_20b
        (non_military_1099rs.sum(&:gross_distribution_amount) - non_military_1099rs.sum(&:taxable_amount)).round
      end

      def calculate_line_27
        line_or_zero(:NJ1040_LINE_15) + line_or_zero(:NJ1040_LINE_16A) + line_or_zero(:NJ1040_LINE_20A)
      end

      def calculate_line_28a
        total_income = line_or_zero(:NJ1040_LINE_27)
        return 0 unless @nj_retirement_income_helper.line_28a_eligible?(total_income)

        total_eligible_nonmilitary_1099r_income = @nj_retirement_income_helper.total_eligible_nonmilitary_1099r_income
        max_exclusion = @nj_retirement_income_helper.calculate_maximum_exclusion(total_income, total_eligible_nonmilitary_1099r_income)
        [total_eligible_nonmilitary_1099r_income, max_exclusion].min
      end

      def calculate_line_28b
        return 0 unless @nj_retirement_income_helper.line_28b_eligible?(
          line_or_zero(:NJ1040_LINE_15),
          line_or_zero(:NJ1040_LINE_27),
          line_or_zero(:NJ1040_LINE_28A))
        
        total_income = line_or_zero(:NJ1040_LINE_27)
        [@nj_retirement_income_helper.calculate_maximum_exclusion(total_income, total_income) - line_or_zero(:NJ1040_LINE_28A),
         @nj_retirement_income_helper.total_eligible_nonretirement_income].min
      end

      def calculate_line_28c
        line_or_zero(:NJ1040_LINE_28A) + line_or_zero(:NJ1040_LINE_28B)
      end

      def calculate_line_29
        [line_or_zero(:NJ1040_LINE_27) - line_or_zero(:NJ1040_LINE_28C), 0].max
      end

      def calculate_line_31
        two_percent_gross = line_or_zero(:NJ1040_LINE_29) * 0.02
        difference_with_med_expenses = @intake.medical_expenses - two_percent_gross
        rounded_difference = difference_with_med_expenses.round
        return rounded_difference if rounded_difference.positive?
        nil
      end

      def calculate_line_38
        line_or_zero(:NJ1040_LINE_13) + line_or_zero(:NJ1040_LINE_31)
      end

      def calculate_line_39
        [line_or_zero(:NJ1040_LINE_29) - line_or_zero(:NJ1040_LINE_38), 0].max
      end

      def is_ineligible_or_unsupported_for_property_tax_credit
        return true if Efile::Nj::NjPropertyTaxEligibility.ineligible?(@intake)

        case @intake.household_rent_own
        when "own"
          StateFile::NjHomeownerEligibilityHelper.determine_eligibility(@intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
        when "rent"
          StateFile::NjTenantEligibilityHelper.determine_eligibility(@intake) == StateFile::NjTenantEligibilityHelper::INELIGIBLE
        when "both"
          StateFile::NjTenantEligibilityHelper.determine_eligibility(@intake) == StateFile::NjTenantEligibilityHelper::INELIGIBLE &&
            StateFile::NjHomeownerEligibilityHelper.determine_eligibility(@intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
        else
          true
        end
      end

      def calculate_line_40a
        if @intake.household_rent_own_both?
          return nil unless @intake.rent_paid&.positive? || @intake.property_tax_paid&.positive?
          property_tax_paid = [@intake.property_tax_paid.to_f, 0].max
          rent_paid = [@intake.rent_paid.to_f * RENT_CONVERSION, 0].max
          is_mfs = @intake.filing_status_mfs?
          
          if is_mfs && @intake.tenant_same_home_spouse_yes?
            rent_paid /= 2
          end
          if is_mfs && @intake.homeowner_same_home_spouse_yes?
            property_tax_paid /= 2
          end

          return (rent_paid + property_tax_paid).round
        end
        
        case @intake.household_rent_own
        when "own"
          return nil unless @intake.property_tax_paid&.positive?
          property_tax_paid = @intake.property_tax_paid
        when "rent"
          return nil unless @intake.rent_paid&.positive?
          property_tax_paid = @intake.rent_paid * RENT_CONVERSION
        else
          return nil
        end

        is_mfs_same_home ? (property_tax_paid / 2.0).round : property_tax_paid.round
      end

      def calculate_line_41
        should_use_property_tax_deduction ? calculate_property_tax_deduction : nil
      end

      def calculate_line_42
        return 0 if @intake.eligibility_made_less_than_threshold?

        if should_use_property_tax_deduction
          [line_or_zero(:NJ1040_LINE_39) - calculate_property_tax_deduction, 0].max
        else
          line_or_zero(:NJ1040_LINE_39)
        end
      end

      def calculate_line_43
        should_use_property_tax_deduction ? calculate_tax_liability_with_deduction.round : calculate_tax_liability_without_deduction.round
      end

      def calculate_line_45
        line_or_zero(:NJ1040_LINE_43)
      end

      def calculate_line_49
        0
      end

      def calculate_line_50
        difference = line_or_zero(:NJ1040_LINE_45) - line_or_zero(:NJ1040_LINE_49)
        [difference, 0].max
      end

      def calculate_line_51
        (@intake.sales_use_tax || 0).round
      end

      def calculate_line_54
        sum = line_or_zero(:NJ1040_LINE_50) + line_or_zero(:NJ1040_LINE_51)
        [sum, 0].max
      end

      def calculate_line_55
        return nil if @intake.state_file_w2s.empty? && @intake.state_file1099_rs.empty?

        (
          @intake.state_file_w2s.sum { |item| item.state_income_tax_amount || 0} +
          @intake.state_file1099_rs.sum(&:state_tax_withheld_amount)
        ).round
      end

      def calculate_line_56
        if should_use_property_tax_deduction || is_ineligible_or_unsupported_for_property_tax_credit
          nil
        else
          is_mfs_same_home ? 25 : 50
        end
      end

      def calculate_line_57
        @intake.estimated_tax_payments&.round
      end

      def calculate_line_58
        if @direct_file_data.fed_eic.positive?
          (@direct_file_data.fed_eic * 0.4).round
        elsif Efile::Nj::NjFlatEitcEligibility.eligible?(@intake)
          240
        else
          0
        end
      end

      def calculate_line_58_irs
        @direct_file_data.fed_eic.positive?
      end

      def get_personal_excess(ssn, get_value_function, threshold)
        persons_w2s = @intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == ssn }
        return 0 unless persons_w2s.count > 1
        return 0 if persons_w2s.any? do |w2|
          excess_value = get_value_function.call(w2)
          excess_value && excess_value > threshold
        end

        total_contribution = persons_w2s.sum do |w2|
          get_value_function.call(w2) || 0
        end

        excess_contribution = total_contribution - threshold
        excess_contribution.positive? ? excess_contribution : 0
      end

      def calculate_line_59
        total_excess = (line_59_primary || 0) + (line_59_spouse || 0)
        total_excess.round if total_excess.positive?
      end

      def calculate_line_60
        0
      end

      def calculate_line_61
        total_excess = (line_61_primary || 0) + (line_61_spouse || 0)
        total_excess.round if total_excess.positive?
      end

      def calculate_line_62
        0
      end

      def calculate_line_63
        0
      end

      def calculate_line_64
        federal_child_and_dependent_care_credit = @direct_file_data.fed_credit_for_child_and_dependent_care_amount
        nj_taxable_income = line_or_zero(:NJ1040_LINE_42)
        if nj_taxable_income <= 30_000
          federal_child_and_dependent_care_credit * 0.5
        elsif nj_taxable_income <= 60_000
          federal_child_and_dependent_care_credit * 0.4
        elsif nj_taxable_income <= 90_000
          federal_child_and_dependent_care_credit * 0.3
        elsif nj_taxable_income <= 120_000
          federal_child_and_dependent_care_credit * 0.2
        elsif nj_taxable_income <= 150_000
          federal_child_and_dependent_care_credit * 0.1
        end
      end

      def calculate_line_65
        return nil if @intake.filing_status == :married_filing_separately

        eligible_dependents_count = number_of_dependents_age_5_younger
        return nil if eligible_dependents_count.zero?

        nj_taxable_income = line_or_zero(:NJ1040_LINE_42)

        case
        when nj_taxable_income <= 30_000
          return eligible_dependents_count * 1000
        when nj_taxable_income <= 40_000
          return eligible_dependents_count * 800
        when nj_taxable_income <= 50_000
          return eligible_dependents_count * 600
        when nj_taxable_income <= 60_000
          return eligible_dependents_count * 400
        when nj_taxable_income <= 80_000
          return eligible_dependents_count * 200
        end
        nil
      end

      def calculate_line_66
        line_or_zero(:NJ1040_LINE_55) +
          line_or_zero(:NJ1040_LINE_56) +
          line_or_zero(:NJ1040_LINE_57) +
          line_or_zero(:NJ1040_LINE_58) +
          line_or_zero(:NJ1040_LINE_59) +
          line_or_zero(:NJ1040_LINE_60) +
          line_or_zero(:NJ1040_LINE_61) +
          line_or_zero(:NJ1040_LINE_62) +
          line_or_zero(:NJ1040_LINE_63) +
          line_or_zero(:NJ1040_LINE_64) +
          line_or_zero(:NJ1040_LINE_65)
      end

      def calculate_line_67
        [line_or_zero(:NJ1040_LINE_54) - line_or_zero(:NJ1040_LINE_66), 0].max
      end

      def calculate_line_68
        [line_or_zero(:NJ1040_LINE_66) - line_or_zero(:NJ1040_LINE_54), 0].max
      end

      def calculate_line_69
        0
      end

      def calculate_line_70
        0
      end

      def calculate_line_71
        0
      end

      def calculate_line_72
        0
      end

      def calculate_line_73
        0
      end

      def calculate_line_74
        0
      end

      def calculate_line_75
        0
      end

      def calculate_line_76
        0
      end

      def calculate_line_77
        0
      end

      def calculate_line_78
        line_or_zero(:NJ1040_LINE_69) +
          line_or_zero(:NJ1040_LINE_70) +
          line_or_zero(:NJ1040_LINE_71) +
          line_or_zero(:NJ1040_LINE_72) +
          line_or_zero(:NJ1040_LINE_73) +
          line_or_zero(:NJ1040_LINE_74) +
          line_or_zero(:NJ1040_LINE_75) +
          line_or_zero(:NJ1040_LINE_76) +
          line_or_zero(:NJ1040_LINE_77)
      end

      def calculate_line_79
        if line_or_zero(:NJ1040_LINE_67).positive?
          return line_or_zero(:NJ1040_LINE_67) + line_or_zero(:NJ1040_LINE_78)
        end
        0
      end

      def calculate_line_79_checkbox
        @intake.payment_or_deposit_type_direct_deposit? && line_or_zero(:NJ1040_LINE_79).positive?
      end

      def calculate_line_80
        if line_or_zero(:NJ1040_LINE_68).positive?
          return [line_or_zero(:NJ1040_LINE_68) - line_or_zero(:NJ1040_LINE_78), 0].max
        end
        0
      end

      def number_of_dependents_age_5_younger
        dep_age_5_younger_count = @intake.dependents.count { |dependent| age_on_last_day_of_tax_year(dependent.dob) <= 5 }
        [dep_age_5_younger_count, MAX_NJ_CTC_DEPENDENTS].min
      end

      def age_on_last_day_of_tax_year(dob)
        last_day_of_tax_year = Date.new(MultiTenantService.new(:statefile).current_tax_year, 12, 31)
        last_day_of_tax_year.year - dob.year
      end

      def number_of_true_checkboxes(checkbox_array_for_line)
        checkbox_array_for_line.sum { |a| a == true ? 1 : 0 }
      end

      def interest_on_gov_bonds
        interest_reports = @intake.direct_file_json_data.interest_reports
        interests_on_gov_bonds = interest_reports&.map(&:interest_on_government_bonds)
        interests_on_gov_bonds&.sum&.round
      end

      def is_mfs_same_home
        is_mfs = @intake.filing_status_mfs?
        is_same_home = @intake.tenant_same_home_spouse_yes? || @intake.homeowner_same_home_spouse_yes?
        is_mfs && is_same_home
      end

      def non_military_1099rs
        @intake.state_file1099_rs.select do |state_file_1099r|
          state_file_1099r.state_specific_followup.present? && state_file_1099r.state_specific_followup.income_source_other?
        end
      end
    end
  end
end
