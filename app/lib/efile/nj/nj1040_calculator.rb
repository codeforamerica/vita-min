module Efile
  module Nj
    class Nj1040Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      RENT_CONVERSION = 0.18
      MAX_NJ_CTC_DEPENDENTS = 9

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:NJ1040_LINE_6_SPOUSE, :line_6_spouse_checkbox)
        set_line(:NJ1040_LINE_6, :calculate_line_6)
        set_line(:NJ1040_LINE_7_SELF, :line_7_self_checkbox)
        set_line(:NJ1040_LINE_7_SPOUSE, :line_7_spouse_checkbox)
        set_line(:NJ1040_LINE_7, :calculate_line_7)
        set_line(:NJ1040_LINE_8, :calculate_line_8)
        set_line(:NJ1040_LINE_13, :calculate_line_13)
        set_line(:NJ1040_LINE_15, :calculate_line_15)
        set_line(:NJ1040_LINE_16A, :calculate_line_16a)
        set_line(:NJ1040_LINE_27, :calculate_line_27)
        set_line(:NJ1040_LINE_29, :calculate_line_29)
        set_line(:NJ1040_LINE_31, :calculate_line_31)
        set_line(:NJ1040_LINE_38, :calculate_line_38)
        set_line(:NJ1040_LINE_39, :calculate_line_39)
        set_line(:NJ1040_LINE_40A, :calculate_line_40a)
        set_line(:NJ1040_LINE_41, :calculate_line_41)
        set_line(:NJ1040_LINE_42, :calculate_line_42)
        set_line(:NJ1040_LINE_43, :calculate_line_43)
        set_line(:NJ1040_LINE_51, :calculate_line_51)
        set_line(:NJ1040_LINE_56, :calculate_line_56)
        set_line(:NJ1040_LINE_58, :calculate_line_58)
        set_line(:NJ1040_LINE_64, :calculate_line_64)
        set_line(:NJ1040_LINE_65_DEPENDENTS, :number_of_dependents_age_5_younger)
        set_line(:NJ1040_LINE_65, :calculate_line_65)
        @lines.transform_values(&:value)
      end

      def analytics_attrs
        {
        }
      end

      def refund_or_owed_amount
        0
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
        if calculate_line_40a.nil?
          return nil
        end

        [calculate_line_40a, limit].min
      end

      def calculate_tax_liability_with_deduction
        return nil if calculate_property_tax_deduction.nil?
        income = calculate_line_39 - calculate_property_tax_deduction
        (rate, subtraction) = get_tax_rate_and_subtraction_amount(income)
        ((income * rate) - subtraction).round(2)
      end

      def calculate_tax_liability_without_deduction
        income = calculate_line_39
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

      private

      def line_6_spouse_checkbox
        @intake.filing_status_mfj?
      end

      def calculate_line_6
        self_exemption = 1
        number_of_line_6_exemptions = self_exemption + number_of_true_checkboxes([line_6_spouse_checkbox])
        number_of_line_6_exemptions * 1_000
      end

      def line_7_self_checkbox
        is_over_65(@intake.primary_birth_date)
      end

      def line_7_spouse_checkbox
        return false unless @intake.spouse_birth_date.present?
        is_over_65(@intake.spouse_birth_date)
      end

      def calculate_line_7
        number_of_line_7_exemptions = number_of_true_checkboxes([line_7_self_checkbox,
                                                                 line_7_spouse_checkbox])
        number_of_line_7_exemptions * 1_000
      end

      def calculate_line_8
        number_of_line_8_exemptions = number_of_true_checkboxes([@direct_file_data.is_primary_blind? || @intake.primary_disabled_yes?,
                                                                 @direct_file_data.is_spouse_blind? || @intake.spouse_disabled_yes?])
        number_of_line_8_exemptions * 1_000
      end

      def calculate_line_13
        line_or_zero(:NJ1040_LINE_6) + line_or_zero(:NJ1040_LINE_7) + line_or_zero(:NJ1040_LINE_8) 
      end

      def calculate_line_15
        if @intake.state_file_w2s.empty?
          return -1
        end

        sum = 0
        @intake.state_file_w2s.each do |w2|
          state_wage = w2.state_wages_amount
          sum += state_wage
        end
        sum
      end

      def calculate_line_16a
        interest_reports = @intake.direct_file_json_data.interest_reports
        interest_on_gov_bonds = interest_reports&.map(&:interest_on_government_bonds)
        interest_sum = interest_on_gov_bonds.sum
        return nil unless interest_sum.positive?
        (@intake.direct_file_data.fed_taxable_income - interest_sum).round
      end

      def calculate_line_27
        calculate_line_15
      end

      def calculate_line_29
        calculate_line_27
      end

      def calculate_line_31
        two_percent_gross = calculate_line_29 * 0.02
        difference_with_med_expenses = @intake.medical_expenses - two_percent_gross
        rounded_difference = difference_with_med_expenses.round
        return rounded_difference if rounded_difference.positive?
        nil
      end

      def calculate_line_38
        calculate_line_13 + line_or_zero(:NJ1040_LINE_31)
      end

      def calculate_line_39
        calculate_line_29 - calculate_line_38
      end

      def is_ineligible_or_unsupported_for_property_tax
        StateFile::NjHomeownerEligibilityHelper.determine_eligibility(@intake) != StateFile::NjHomeownerEligibilityHelper::ADVANCE
      end

      def calculate_line_40a
        case @intake.household_rent_own
        when "own"
          if @intake.property_tax_paid.nil?
            return nil
          end
          property_tax_paid = @intake.property_tax_paid
        when "rent"
          if @intake.rent_paid.nil?
            return nil
          end
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
        should_use_property_tax_deduction ? calculate_line_39 - calculate_property_tax_deduction : calculate_line_39
      end

      def calculate_line_43
        should_use_property_tax_deduction ? calculate_tax_liability_with_deduction.round : calculate_tax_liability_without_deduction.round
      end

      def calculate_line_51
        @intake.sales_use_tax || 0
      end

      def calculate_line_56
        if should_use_property_tax_deduction || is_ineligible_or_unsupported_for_property_tax
          nil
        else
          is_mfs_same_home ? 25 : 50
        end
      end

      def calculate_line_58
        (@direct_file_data.fed_eic * 0.4).round
      end

      def calculate_line_64
        federal_child_and_dependent_care_credit = @direct_file_data.fed_credit_for_child_and_dependent_care_amount
        nj_taxable_income = calculate_line_42
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

        nj_taxable_income = calculate_line_42

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

      def number_of_dependents_age_5_younger
        dep_age_5_younger_count = @intake.dependents.count { |dependent| age_on_last_day_of_tax_year(dependent.dob) <= 5 }
        [dep_age_5_younger_count, MAX_NJ_CTC_DEPENDENTS].min
      end

      def is_over_65(birth_date)
        over_65_birth_year = MultiTenantService.new(:statefile).current_tax_year - 65
        birth_date <= Date.new(over_65_birth_year, 12, 31)
      end

      def age_on_last_day_of_tax_year(dob)
        last_day_of_tax_year = Date.new(MultiTenantService.new(:statefile).current_tax_year, 12, 31)
        last_day_of_tax_year.year - dob.year
      end

      def number_of_true_checkboxes(checkbox_array_for_line)
        checkbox_array_for_line.sum { |a| a == true ? 1 : 0 }
      end

      def is_mfs_same_home
        is_mfs = @intake.filing_status_mfs?
        is_same_home = @intake.tenant_same_home_spouse_yes? || @intake.homeowner_same_home_spouse_yes?
        is_mfs && is_same_home
      end
    end
  end
end
