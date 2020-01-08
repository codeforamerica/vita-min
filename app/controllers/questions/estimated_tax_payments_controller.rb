module Questions
  class EstimatedTaxPaymentsController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Life Events"
    end
  end
end