module Ctc
  module Questions
    module Dependents
      class ChildDisqualifiersController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent

          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition_2020?
        end

        private

        def illustration_path; end
      end
    end
  end
end
