module Ctc
  module Questions
    module Dependents
      class NoDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_no?
        end

        private

        def form_class
          NullForm
        end

        def illustration_path
          "hand-holding-check.svg"
        end
      end
    end
  end
end
