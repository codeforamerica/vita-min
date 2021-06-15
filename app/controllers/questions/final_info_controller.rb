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
      is_drop_off_client = @client.tax_returns.pluck(:service_type).any? "drop_off"

      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        email_body: is_drop_off_client ? I18n.t("messages.successful_submission_drop_off.email_body") : I18n.t("messages.successful_submission_online_intake.email_body"),
        sms_body: is_drop_off_client ? I18n.t("messages.successful_submission_drop_off.sms_body") : I18n.t("messages.successful_submission_online_intake.sms_body"),
        subject: is_drop_off_client ? I18n.t("messages.successful_submission_drop_off.subject") : I18n.t("messages.successful_submission_online_intake.subject"),
        locale: I18n.locale
      )
    end
  end
end
