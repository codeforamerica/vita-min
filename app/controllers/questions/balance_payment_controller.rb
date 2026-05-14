module Questions
  class BalancePaymentController < QuestionsController
    include AuthenticatedClientConcern

    layout 'yes_no_question'

    def self.show?(intake)
      intake.refund_direct_deposit_yes?
    end

    private

    def method_name
      "balance_pay_from_bank"
    end
  end
end
