module Ctc
  module Questions
    module Dependents
      class ChildDisqualifiersController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent

          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition?
        end

        def self.model_for_show_check(current_controller)
          current_resource_from_params(current_controller.visitor_record, current_controller.params)
        end

        def edit
          super
        end

        def update
          super
        end

        private

        def illustration_path; end
      end
    end
  end
end

# determines --> dependent.meets_qc_misc_conditions?
# provided_over_half_own_support_no? && no_ssn_atin_no? && filed_joint_return_no?