module Efile
  module Nj
    module NjFlatEitcEligibility
      class << self
        def possibly_eligible?(intake)
          return false if intake.direct_file_data.fed_eic.positive?

          true
        end
      end
    end
  end
end
