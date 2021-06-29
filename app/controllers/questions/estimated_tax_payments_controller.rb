module Questions
  class EstimatedTaxPaymentsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "made_estimated_tax_payments"
    end
  end
end