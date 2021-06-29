module Questions
  class RetirementIncomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.had_social_security_or_retirement_yes? || intake.had_social_security_or_retirement_unsure?
    end

    private

    def illustration_path
      "hand-holding-check.svg"
    end

    def method_name
      "had_retirement_income"
    end
  end
end
