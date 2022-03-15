module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "yes_no_question"

        private

        def illustration_path; end
      end
    end
  end
end
