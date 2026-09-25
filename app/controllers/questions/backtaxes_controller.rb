module Questions
  class BacktaxesController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"

    private
    def after_update_success
      #moved from interview_scheduling_controller because we now need to check for prior year need before routing
      if current_intake.client.routing_method.blank? || current_intake.client.routing_method_at_capacity?
        PartnerRoutingService.update_intake_partner(current_intake)
      end
    end

    def illustration_path
      "calendar.svg"
    end

  end
end
