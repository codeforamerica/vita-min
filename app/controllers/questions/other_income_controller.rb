module Questions
  class OtherIncomeController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "had_other_income"
    end
  end
end