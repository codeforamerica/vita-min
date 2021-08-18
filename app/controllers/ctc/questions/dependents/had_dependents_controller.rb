module Ctc
  module Questions
    module Dependents
      class HadDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "yes_no_question"

        private

        def after_update_success
          if current_intake.had_dependents_yes?
            session[:last_edited_dependent_id] = current_intake.find_blank_dependent_or_create_dependent.id
          end
        end

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
