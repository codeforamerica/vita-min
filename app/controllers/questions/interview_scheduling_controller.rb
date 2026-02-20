module Questions
  class InterviewSchedulingController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def edit
      super
    end

    private

    def after_update_success
      PartnerRoutingService.update_intake_partner(current_intake)
    end

    def tracking_data
      {}
    end

    def illustration_path
      "phone-number.svg"
    end
  end
end
