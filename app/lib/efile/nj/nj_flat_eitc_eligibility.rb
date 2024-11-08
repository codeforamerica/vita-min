module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          return false if intake.filing_status_mfs?

          return false if intake.direct_file_data.fed_tax_exempt_interest + intake.direct_file_data.fed_taxable_income >= 11_600

          true
        end
      end
    end
  end
end
