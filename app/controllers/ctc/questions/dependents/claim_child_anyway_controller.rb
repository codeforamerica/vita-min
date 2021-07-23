module Ctc
  module Questions
    module Dependents
      class ClaimChildAnywayController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent
          dependent.qualifying_child_relationship? &&
            dependent.meets_qc_age_condition_2020? &&
            dependent.meets_qc_misc_conditions? &&
            dependent.meets_qc_residence_condition_2020? &&
            dependent.can_be_claimed_by_other_yes?
        end

        def self.model_for_show_check(current_controller)
          current_resource_from_params(current_controller.visitor_record, current_controller.params)
        end

        def method_name
          'claim_regardless'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
