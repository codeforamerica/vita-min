module Questions
  class RefundPaymentController < QuestionsController
    include AuthenticatedClientConcern

    layout 'yes_no_question'

    private

    def method_name
      'refund_direct_deposit'
    end

    def has_unsure_option?
      false
    end
  end
end
