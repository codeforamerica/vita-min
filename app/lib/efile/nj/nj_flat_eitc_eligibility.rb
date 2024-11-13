module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          return false if intake.filing_status_mfs?

          return false if investment_income_over_limit?(intake)

          return false if intake.direct_file_data.fed_wages_salaries_tips <= 0

          return false unless meets_age_requirements?(intake)

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
            ((primary_age_exclusive < lower_age_range_years || primary_age_inclusive >= upper_age_range_years) &&
            (spouse_age_exclusive < lower_age_range_years || spouse_age_inclusive >= upper_age_range_years))
          else
            primary_age_exclusive >= minimum_age_years &&
            (primary_age_exclusive < lower_age_range_years || primary_age_inclusive >= upper_age_range_years)
          end
        end
      end
    end
  end
end
