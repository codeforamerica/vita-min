module Questions
  class OtherIncomeTypesController < TicketedQuestionsController
    layout "question"

    def self.show?(intake)
      intake.had_other_income_yes?
    end

    def tracking_data
      {}
    end
  end
end