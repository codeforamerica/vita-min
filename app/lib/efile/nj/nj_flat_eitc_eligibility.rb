module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def eligible?(intake)
          possibly_eligible?(intake) &&
          intake.claimed_as_eitc_qualifying_child_no? &&
          (!intake.filing_status_mfj? || intake.spouse_claimed_as_eitc_qualifying_child_no?)
        end

        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          return false if intake.filing_status_mfs?

          return false if investment_income_over_limit?(intake)

          return false if intake.direct_file_data.fed_wages_salaries_tips <= 0

          return false unless meets_age_requirements?(intake)

          return false unless is_under_income_total_limit?(intake)

          return false unless has_ssn_valid_for_employment?(intake)

          return false if claimed_as_dependent?(intake)

          true
        end

        def investment_income_over_limit?(intake)
          intake.direct_file_data.fed_tax_exempt_interest + intake.direct_file_data.fed_taxable_income >= 11_600
        end

        def meets_age_requirements?(intake)
          minimum_age_years = 18
          lower_age_range_years = 25
          upper_age_range_years = 65

          primary_age_exclusive = intake.calculate_age(intake.primary_birth_date, inclusive_of_jan_1: false)
          primary_age_inclusive = intake.calculate_age(intake.primary_birth_date, inclusive_of_jan_1: true)

          if intake.filing_status_mfj?
            spouse_age_exclusive = intake.calculate_age(intake.spouse_birth_date, inclusive_of_jan_1: false)
            spouse_age_inclusive = intake.calculate_age(intake.spouse_birth_date, inclusive_of_jan_1: true)

            (primary_age_exclusive >= minimum_age_years || spouse_age_exclusive >= minimum_age_years) &&
            ((primary_age_inclusive < lower_age_range_years || primary_age_inclusive >= upper_age_range_years) &&
            (spouse_age_inclusive < lower_age_range_years || spouse_age_inclusive >= upper_age_range_years))
          else
            primary_age_exclusive >= minimum_age_years &&
            (primary_age_inclusive < lower_age_range_years || primary_age_inclusive >= upper_age_range_years)
          end
        end

        def is_under_income_total_limit?(intake)
          if intake.filing_status_mfj?
            intake.direct_file_data.fed_income_total < 24_210
          else
            intake.direct_file_data.fed_income_total < 17_640
          end
        end

        def has_ssn_valid_for_employment?(intake)
          return false if intake.primary.has_itin?
          return false if intake.direct_file_json_data.primary_filer.ssnNotValidForEmployment

          if intake.filing_status_mfj? && intake.direct_file_json_data.spouse_filer.present?
            return false if intake.spouse.has_itin?
            return false if intake.direct_file_json_data.spouse_filer.ssnNotValidForEmployment
          end

          true
        end

        def claimed_as_dependent?(intake)
          intake.direct_file_data.claimed_as_dependent? ||
          (intake.filing_status_mfj? && intake.direct_file_data.spouse_is_a_dependent?)
        end
      end
    end
  end
end
