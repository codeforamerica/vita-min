module Ctc
  module Questions
    module Dependents
      class ChildResidenceExceptionsController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "yes_no_question"

        def method_name
          "permanent_residence_with_client"
        end

        private

        def illustration_path; end
      end
    end
  end
end
