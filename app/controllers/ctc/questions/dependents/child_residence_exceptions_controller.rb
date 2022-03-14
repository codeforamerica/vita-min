module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent&.relationship

          dependent.qualifying_child_relationship? && dependent.yr_2021_meets_qc_age_condition? && dependent.meets_qc_misc_conditions? && dependent.lived_with_more_than_six_months_no? && !dependent.born_in_final_6_months_of_tax_year?(2020)
        end

        private

        def illustration_path; end
      end
    end
  end
end
