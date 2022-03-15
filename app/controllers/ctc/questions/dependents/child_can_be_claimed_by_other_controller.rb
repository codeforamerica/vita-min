module Ctc
  module Questions
    module Dependents
      class ChildCanBeClaimedByOtherController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'cant_be_claimed_by_other'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
