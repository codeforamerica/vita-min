module Ctc
  module Questions
    module Dependents
      class ChildClaimAnywayController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
