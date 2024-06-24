module Questions
  class DisabilityIncomeController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "had_disability_income"
    end
  end
end