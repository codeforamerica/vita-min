module Questions
  class OtherIncomeTypesController < QuestionsController
    layout "question"

    def section_title
      "Income and Expenses"
    end

    def self.show?(intake)
      intake.had_other_income_yes?
    end
  end
end