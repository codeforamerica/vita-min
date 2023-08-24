module Ctc
  module Questions
    module Dependents
      class ChildResidenceController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        private

        def illustration_path
          "dependents_home.svg"
        end
      end
    end
  end
end
