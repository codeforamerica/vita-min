module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false unless dependent&.relationship

          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition_2020? && dependent.meets_qc_misc_conditions? && dependent.lived_with_more_than_six_months_no? && !dependent.yr_2020_born_in_last_6_months?
        end

        private

        def illustration_path; end
      end
    end
  end
end
