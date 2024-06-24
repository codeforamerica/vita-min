module Questions
  class SocialSecurityIncomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.had_social_security_or_retirement_yes? || intake.had_social_security_or_retirement_unsure?
    end

    def method_name
      "had_social_security_income"
    end
  end
end
