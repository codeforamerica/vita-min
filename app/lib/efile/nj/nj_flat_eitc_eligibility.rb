module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          return false if intake.filing_status_mfs?

          return false if investment_income_over_limit?(intake)

          return false if intake.direct_file_data.fed_wages_salaries_tips <= 0

          return false unless meets_age_minimum?(intake)

          true
        end

        def investment_income_over_limit?(intake)
          intake.direct_file_data.fed_tax_exempt_interest + intake.direct_file_data.fed_taxable_income >= 11_600
        end

        def meets_age_minimum?(intake)
          minimum_age_years = 18
          if intake.filing_status_mfj?
            return intake.calculate_age(intake.primary_birth_date, inclusive_of_jan_1: true) >= minimum_age_years ||
              intake.calculate_age(intake.spouse_birth_date, inclusive_of_jan_1: true) >= minimum_age_years
          else
            intake.calculate_age(intake.primary_birth_date, inclusive_of_jan_1: true) >= minimum_age_years
          end
        end
      end
    end
  end
end
