module Ctc
  module Questions
    module Dependents
      class HadDependentsController < QuestionsController
        # TODO: Transition to Authenticated once we log in client
        include AnonymousIntakeConcern

        layout "yes_no_question"

        private

        def next_path
          if current_intake.had_dependents_yes?
            Ctc::Questions::Dependents::InfoController.to_path_helper(id: :new)
          else
            super
          end
        end

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
