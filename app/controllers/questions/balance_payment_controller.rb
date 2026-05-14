module Questions
  class BalancePaymentController < QuestionsController
    include AuthenticatedClientConcern

    layout 'yes_no_question'

    def self.show?(intake)
      intake.refund_direct_deposit_yes?
    end

    def next_path
      next_step = Navigation::DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end

    private

    def method_name
      "balance_pay_from_bank"
    end
  end
end
