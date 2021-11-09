module Ctc
  module Questions
    module Dependents
      class ChildDisqualifiersController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent&.relationship

          dependent.qualifying_child_relationship? && dependent.yr_2020_meets_qc_age_condition? && dependent.yr_2020_age >= 0
        end

        private

        def illustration_path; end
      end
    end
  end
end
