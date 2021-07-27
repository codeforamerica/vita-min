module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false unless dependent
          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition_2020? && dependent.meets_qc_misc_conditions? && dependent.lived_with_more_than_six_months_no?
        end

        private

        def illustration_path; end
      end
    end
  end
end
