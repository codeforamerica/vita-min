module Questions
  class BalancePaymentController < TicketedQuestionsController
    layout "yes_no_question"

    private

    def illustration_path
      "banking.svg"
    end
  end
end
