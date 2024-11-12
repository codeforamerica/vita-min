module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          return false if intake.filing_status_mfs?

          return false if investment_income_over_limit?(intake)

          return false if intake.direct_file_data.fed_wages_salaries_tips <= 0

          true
        end

        def investment_income_over_limit?(intake)
          intake.direct_file_data.fed_tax_exempt_interest + intake.direct_file_data.fed_taxable_income >= 11_600
        end
      end
    end
  end
end
