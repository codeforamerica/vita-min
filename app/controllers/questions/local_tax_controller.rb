module Questions
  class LocalTaxController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "paid_local_tax"
    end
  end
end
