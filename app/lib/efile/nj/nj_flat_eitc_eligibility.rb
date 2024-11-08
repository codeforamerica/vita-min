module Efile
  module Nj
    module NjFlatEitcEligibility
      INELIGIBLE = :ineligible
      POSSIBLY_ELIGIBLE = :possibly_eligible

      class << self
        def ineligible?(intake)
          determine_eligibility(intake) == INELIGIBLE
        end

        def possibly_eligible?(intake)
          determine_eligibility(intake) == POSSIBLY_ELIGIBLE
        end

        def determine_eligibility(intake)
          # TODO: much logic
          POSSIBLY_ELIGIBLE
        end
      end
    end
  end
end
