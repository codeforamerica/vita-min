module Questions
  class MortgageInterestController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_owned_home_yes?
    end

    private

    def method_name
      "paid_mortgage_interest"
    end
  end
end
