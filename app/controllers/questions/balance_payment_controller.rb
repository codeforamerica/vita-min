module Questions
  class BalancePaymentController < QuestionsController
    include AuthenticatedClientConcern

    private

    def method_name
      "balance_pay_from_bank"
    end

    def form_params
      params.fetch(:balance_payment_form, {}).permit(:balance_payment_choice, :balance_pay_from_bank, :payment_in_installments)
    end
  end
end
