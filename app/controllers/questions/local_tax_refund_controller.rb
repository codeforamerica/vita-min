module Questions
  class LocalTaxRefundController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def illustration_path
      "hand-holding-check.svg"
    end
    
    def method_name
      "had_local_tax_refund"
    end
  end
end