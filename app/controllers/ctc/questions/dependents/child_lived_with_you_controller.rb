module Ctc
  module Questions
    module Dependents
      class ChildLivedWithYouController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent&.relationship

          dependent.qualifying_child_relationship? && dependent.meets_qc_age_condition_2020? && dependent.meets_qc_misc_conditions?
        end

        def method_name
          'lived_with_more_than_six_months'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
