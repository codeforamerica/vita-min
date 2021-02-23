module Questions
  class SocialSecurityOrRetirementController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "retirement-income.svg"
    end
  end
end
