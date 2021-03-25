module Questions
  class NotificationPreferenceController < AnonymousIntakeController
    private

    def tracking_data
      @form.attributes_for(:intake).reject { |k, _| k == :sms_phone_number }
    end

    def after_update_success
      if @form.intake.sms_notification_opt_in_yes?
        ClientMessagingService.send_system_text_message(
          @form.intake.client,
          I18n.t(
            "messages.sms_opt_in",
            locale: current_intake.locale,
          )
        )
      end
    end
  end
end
