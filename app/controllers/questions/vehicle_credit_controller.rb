module Questions
  class VehicleCreditController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "new_vehicle_purchased"
    end
  end
end