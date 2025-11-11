module Questions
  class InterviewSchedulingController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def edit
      super
    end

    private

    def after_update_success
      if current_intake.client.routing_method.blank? || current_intake.client.routing_method_at_capacity?
        PartnerRoutingService.update_intake_partner(current_intake)
      end
    end

    def tracking_data
      {}
    end

    def illustration_path
      "phone-number.svg"
    end
  end
end
