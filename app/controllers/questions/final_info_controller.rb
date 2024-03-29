module Questions
  class FinalInfoController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    private

    def after_update_success
      current_intake.update(completed_at: Time.now)
      GenerateF13614cPdfJob.perform_later(current_intake.id, "Original 13614-C.pdf")

      MixpanelService.send_event(
        distinct_id: current_intake.visitor_id,
        event_name: "intake_finished",
        data: MixpanelService.data_from([current_intake.client, current_intake])
      )
      send_confirmation_message
    end

    def tracking_data
      {}
    end

    def send_confirmation_message
      @client = current_intake.client

      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        message: AutomatedMessage::SuccessfulSubmissionOnlineIntake,
        locale: I18n.locale
      )
    end
  end
end
