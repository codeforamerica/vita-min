module Ctc
  module Questions
    class HadDependentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      private

      def next_path
        if current_intake.dependents.count > 0 # If the client has already added dependents, take them to the confirmation page to add more or continue.
          questions_confirm_dependents_path
        elsif current_intake.had_dependents_no?
          super
        else
          Ctc::Questions::Dependents::InfoController.to_path_helper(id: current_intake.new_dependent_token)
        end
      end

      def illustration_path
        "dependents.svg"
      end
    end
  end
end
