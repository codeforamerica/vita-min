module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false unless dependent
          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition? && dependent.meets_qc_misc_conditions? && dependent.lived_with_less_than_six_months_yes?
        end

        def self.model_for_show_check(current_controller)
          current_resource_from_params(current_controller.visitor_record, current_controller.params)
        end

        private

        def illustration_path; end
      end
    end
  end
end
