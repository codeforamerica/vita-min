module Questions
  class BalancePaymentController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "balance_pay_from_bank"
    end
  end
end
