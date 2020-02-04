module Questions
  class RetirementContributionsController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Expenses"
    end

    def no_illustration?
      true
    end
  end
end