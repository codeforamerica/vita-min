module Questions
  class AdditionalInfoController < TicketedQuestionsController
    layout "question"

    def after_update_success
      if current_intake.eip_only?
        SendEipIntakeConsentToZendeskJob.perform_later(current_intake.id)
      else
        SendIntakePdfToZendeskJob.perform_later(current_intake.id)
      end
    end

    def tracking_data
      {}
    end
  end
end
