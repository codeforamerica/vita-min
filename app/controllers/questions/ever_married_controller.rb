module Questions
  class EverMarriedController < TicketedQuestionsController
    layout "yes_no_question"

    def illustration_path
      "married.svg"
    end
  end
end
