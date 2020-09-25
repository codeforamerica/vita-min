module Questions
  class SoldAssetsController < TicketedQuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end
  end
end