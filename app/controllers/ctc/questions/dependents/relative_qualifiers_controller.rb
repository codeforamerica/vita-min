module Ctc
  module Questions
    module Dependents
      class RelativeQualifiersController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        private

        def illustration_path; end
      end
    end
  end
end
