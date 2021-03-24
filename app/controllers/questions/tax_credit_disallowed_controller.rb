module Questions
  class TaxCreditDisallowedController < AuthenticatedIntakeController
    layout "yes_no_question"

    private

    def method_name
      "had_tax_credit_disallowed"
    end
  end
end