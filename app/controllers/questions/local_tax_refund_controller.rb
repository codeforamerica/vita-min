module Questions
  class LocalTaxRefundController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "had_local_tax_refund"
    end
  end
end