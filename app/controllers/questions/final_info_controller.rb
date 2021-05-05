module Questions
  class FinalInfoController < AuthenticatedIntakeController
    layout "intake"

    private

    def after_update_success
      current_intake.update(completed_at: Time.now)
      IntakePdfJob.perform_later(current_intake.id, "Original 13614-C.pdf")

      MixpanelService.send_event(
        event_id: current_intake.visitor_id,
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
        current_intake.client,
        email_body: I18n.t(
          "messages.successful_submission.sms_body",
          locale: current_intake.locale,
          preferred_name: current_intake.preferred_name,
          client_id: current_intake.client_id,
          portal_login_url: new_portal_client_login_url(locale: current_intake.locale)
        ),
        sms_body: I18n.t(
          "messages.successful_submission.email_body",
          locale: current_intake.locale,
          preferred_name: current_intake.preferred_name,
          client_id: current_intake.client_id,
          portal_login_url: new_portal_client_login_url(locale: current_intake.locale)
        ),
        subject: I18n.t("messages.successful_submission.subject", locale: current_intake.locale)
      )
    end
  end
end
