module Questions
  class WagesController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end
  end
end