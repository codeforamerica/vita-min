module Questions
  class DivorcedYearController < TicketedQuestionsController
    layout "question"

    def self.show?(intake)
      intake.divorced_yes?
    end

    def illustration_path; end
  end
end
