module Questions
  class EstimatedTaxPaymentsController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "made_estimated_tax_payments"
    end
  end
end