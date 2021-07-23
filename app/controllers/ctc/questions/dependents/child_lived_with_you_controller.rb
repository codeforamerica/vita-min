module Ctc
  module Questions
    module Dependents
      class ChildLivedWithYouController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(_intake, dependent)
          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition? && dependent.meets_qc_misc_conditions?
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
