module Ctc
  module Questions
    module Dependents
      class QualifyingRelativeController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent
          
          (dependent.qualifying_child_relationship? &&
            (!dependent.meets_qc_age_condition_2020? ||
              (dependent.meets_qc_age_condition_2020? && dependent.provided_over_half_own_support_no? && dependent.no_ssn_atin_no? && dependent.filed_joint_return_yes?))) ||
            dependent.qualifying_relative_relationship?
        end

        def method_name
          'meets_misc_qualifying_relative_requirements'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
