module Ctc
  module Questions
    module Dependents
      class ChildClaimAnywayController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'claim_anyway'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
