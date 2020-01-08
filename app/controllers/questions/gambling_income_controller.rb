module Questions
  class GamblingIncomeController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Income"
    end
  end
end