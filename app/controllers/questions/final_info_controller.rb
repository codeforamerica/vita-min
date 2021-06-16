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

      message_class = is_drop_off_client ? AutomatedMessage::SuccessfulSubmissionDropOff : AutomatedMessage::SuccessfulSubmissionOnlineIntake

      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        message: message_class.new,
        locale: I18n.locale
      )
    end
  end
end
