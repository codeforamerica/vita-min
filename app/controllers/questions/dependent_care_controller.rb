module Questions
  class DependentCareController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def method_name
      "paid_dependent_care"
    end
  end
end
