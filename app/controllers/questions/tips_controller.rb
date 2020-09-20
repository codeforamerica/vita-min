module Questions
  class TipsController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end
  end
end