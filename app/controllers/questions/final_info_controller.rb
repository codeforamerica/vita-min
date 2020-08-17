module Questions
  class FinalInfoController < TicketedQuestionsController
    layout "question"

    def illustration_path; end

    def after_update_success
      if current_intake.eip_only?
        SendCompletedEipIntakeToZendeskJob.perform_later(current_intake.id)
      else
        SendCompletedIntakeToZendeskJob.perform_later(current_intake.id)

        # after this point, one of two things will be true: either
        # current_intake.completed_intake_sent_to_zendesk will be true (having
        # been set by the job above) or there will be an error in the logs stating
        # "Unable to send everything to Zendesk"
        current_intake.update(completed_at: Time.now)
      end
    end

    def tracking_data
      {}
    end
  end
end
