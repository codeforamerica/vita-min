module Questions
  class LocalTaxController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "paid_local_tax"
    end
  end
end
