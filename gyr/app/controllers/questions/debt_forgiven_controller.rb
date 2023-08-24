module Questions
  class DebtForgivenController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "had_debt_forgiven"
    end
  end
end