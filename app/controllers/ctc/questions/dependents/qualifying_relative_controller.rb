module Ctc
  module Questions
    module Dependents
      class QualifyingRelativeController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def self.show?(dependent)
          return false unless dependent&.relationship

          # For family members like uncle, we need to show the qualifying relative page.
          # For children, there are special rules that could make them not a qualifying relative, in which case we wouldn't show this page.
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
