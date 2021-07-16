module Ctc
  module Questions
    module Dependents
      class NoDependentsController < QuestionsController
        # TODO: Transition to Authenticated once we log in client
        include AnonymousIntakeConcern

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
