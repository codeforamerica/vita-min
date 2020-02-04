module Questions
  class SocialSecurityIncomeController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Income and Expenses"
    end

    def no_illustration?
      true
    end
  end
end