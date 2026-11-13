module Questions
  class SocialSecurityOrRetirementController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def method_name
      "had_social_security_or_retirement"
    end
  end
end
