module Questions
  class SocialSecurityOrRetirementController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end

    def method_name
      "had_social_security_or_retirement"
    end
  end
end
