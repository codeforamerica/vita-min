module Ctc
  module Questions
    module Dependents
      class ConfirmDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        private

        def form_class
          NullForm
        end

        def illustration_path; end
      end
    end
  end
end
