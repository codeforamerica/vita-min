module Questions
  class SpouseHadDisabilityController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end

    def illustration_path
      "had-disability.svg"
    end
  end
end
