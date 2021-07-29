module Ctc
  module Questions
    module Dependents
      class ChildCanBeClaimedByOtherController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent&.relationship

          dependent.qualifying_child_relationship? &&
            dependent.meets_qc_age_condition_2020? &&
            dependent.meets_qc_misc_conditions? &&
            dependent.meets_qc_residence_condition_2020?
        end

        def method_name
          'cant_be_claimed_by_other'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
