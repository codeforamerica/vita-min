module Ctc
  module Questions
    module Dependents
      class ConfirmDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        private

        def form_class
          NullForm
        end

        def illustration_path
        end
      end
    end
  end
end
