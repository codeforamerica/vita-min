module Questions
  class RetirementContributionsController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.had_social_security_or_retirement_yes?
    end

    private

    def method_name
      "paid_retirement_contributions"
    end
  end
end
