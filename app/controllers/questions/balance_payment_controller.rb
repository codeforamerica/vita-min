module Questions
  class BalancePaymentController < QuestionsController
    include AuthenticatedClientConcern

    private

    def method_name
      "balance_pay_from_bank"
    end
  end
end
