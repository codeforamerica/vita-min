module Questions
  class OtherIncomeTypesController < QuestionsController
    layout "question"

    def self.show?(intake)
      !intake.had_other_income_no?
    end
  end
end