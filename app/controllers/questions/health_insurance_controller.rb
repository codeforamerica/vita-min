module Questions
  class HealthInsuranceController < QuestionsController
    layout "yes_no_question"

    def method_name
      "bought_health_insurance"
    end
  end
end
