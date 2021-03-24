module Questions
  class InterestIncomeController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "had_interest_income"
    end
  end
end