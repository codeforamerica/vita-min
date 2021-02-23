module Questions
  class InterestIncomeController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "had_interest_income"
    end
  end
end