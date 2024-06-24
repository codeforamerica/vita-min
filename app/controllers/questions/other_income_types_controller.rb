module Questions
  class OtherIncomeTypesController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.had_other_income_yes?
    end

    def tracking_data
      {}
    end

    def illustration_path
      "other-income.svg"
    end
  end
end