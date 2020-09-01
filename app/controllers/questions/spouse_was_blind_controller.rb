module Questions
  class SpouseWasBlindController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end

    def illustration_path
      "was-blind.svg"
    end
  end
end