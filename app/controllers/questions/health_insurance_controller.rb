module Questions
  class HealthInsuranceController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Expenses"
    end

    def no_illustration?
      true
    end
  end
end