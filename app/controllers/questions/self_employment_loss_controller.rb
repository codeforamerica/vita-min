module Questions
  class SelfEmploymentLossController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      !intake.had_self_employment_income_no?
    end
  end
end