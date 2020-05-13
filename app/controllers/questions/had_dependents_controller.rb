module Questions
  class HadDependentsController < TicketedQuestionsController
    layout "yes_no_question"

    def next_path
      if current_intake.had_dependents_yes?
        dependents_path
      else
        super
      end
    end
  end
end