module Questions
  class BalancePaymentController < QuestionsController
    layout "yes_no_question"

    private

    def illustration_path
      "banking.svg"
    end

    def method_name
      "balance_pay_from_bank"
    end
  end
end
