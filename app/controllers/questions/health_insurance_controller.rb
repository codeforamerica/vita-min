module Questions
  class HealthInsuranceController < AuthenticatedIntakeController
    layout "yes_no_question"

    def method_name
      "bought_health_insurance"
    end
  end
end
