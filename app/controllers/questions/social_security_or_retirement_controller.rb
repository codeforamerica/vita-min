module Questions
  class SocialSecurityOrRetirementController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end
  end
end
