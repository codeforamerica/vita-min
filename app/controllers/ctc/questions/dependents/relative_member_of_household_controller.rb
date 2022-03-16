module Ctc
  module Questions
    module Dependents
      class RelativeMemberOfHouseholdController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'residence_lived_with_all_year'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
