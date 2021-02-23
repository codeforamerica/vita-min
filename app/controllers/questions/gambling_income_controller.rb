module Questions
  class GamblingIncomeController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "had_gambling_income"
    end
  end
end