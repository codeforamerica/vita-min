module Questions
  class HealthInsuranceController < QuestionsController
    include AuthenticatedClientConcern

    def method_name
      "bought_health_insurance"
    end
  end
end
