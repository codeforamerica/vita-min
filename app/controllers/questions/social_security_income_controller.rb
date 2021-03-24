module Questions
  class SocialSecurityIncomeController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.had_social_security_or_retirement_yes?
    end

    def method_name
      "had_social_security_income"
    end
  end
end
