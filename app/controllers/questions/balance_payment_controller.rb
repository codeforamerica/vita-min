module Questions
  class BalancePaymentController < QuestionsController
    layout "yes_no_question"

    private

    def illustration_path
      "banking.svg"
    end
  end
end
