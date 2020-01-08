module Questions
  class CharitableContributionsController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Expenses"
    end
  end
end