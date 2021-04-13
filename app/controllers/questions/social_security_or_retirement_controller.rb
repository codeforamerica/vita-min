module Questions
  class SocialSecurityOrRetirementController < AuthenticatedIntakeController
    layout "yes_no_question"

    def illustration_path
      "hand-holding-check.svg"
    end

    def method_name
      "had_social_security_or_retirement"
    end
  end
end
