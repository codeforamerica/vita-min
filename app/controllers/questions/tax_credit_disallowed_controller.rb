module Questions
  class TaxCreditDisallowedController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "had_tax_credit_disallowed"
    end
  end
end