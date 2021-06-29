module Questions
  class RetirementContributionsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.had_social_security_or_retirement_yes? || intake.had_social_security_or_retirement_unsure?
    end

    private

    def method_name
      "paid_retirement_contributions"
    end
  end
end
