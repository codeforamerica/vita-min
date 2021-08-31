module Ctc
  module Questions
    module Dependents
      class QualifyingRelativeController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent&.relationship

          # For family members like uncle, we need to show the qualifying relative page.
          # For children, we show the page if they do not meet the age conditions
          dependent.qualifying_relative_relationship? || dependent.disqualified_child_qualified_relative?
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
