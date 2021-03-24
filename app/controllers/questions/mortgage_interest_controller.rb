module Questions
  class MortgageInterestController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "paid_mortgage_interest"
    end
  end
end
