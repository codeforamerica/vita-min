module Ctc
  module Questions
    module Dependents
      class QualifyingRelativeController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent

          dependent.qualifying_relative_relationship? || disqualified_child_qualified_relative?(dependent)
        end

        def method_name
          'meets_misc_qualifying_relative_requirements'
        end

        private

        def self.disqualified_child_qualified_relative?(dependent)
          return false unless dependent.qualifying_child_relationship?

          !dependent.meets_qc_age_condition_2020? || (dependent.meets_qc_age_condition_2020? && qualified_dependent_disqualified_child?(dependent))
        end

        def self.qualified_dependent_disqualified_child?(dependent)
          dependent.provided_over_half_own_support_no? && dependent.no_ssn_atin_no? && dependent.filed_joint_return_yes?
        end

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
