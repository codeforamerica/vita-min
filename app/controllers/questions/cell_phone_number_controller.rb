module Questions
  class CellPhoneNumberController < QuestionsController
    include AnonymousIntakeConcern

    def tracking_data
      {}
    end

    def self.show?(intake)
      intake.sms_phone_number.blank? && intake.sms_notification_opt_in_yes?
    end

    def illustration_path
      "phone-number.svg"
    end

    def after_update_success
      if @form.intake.sms_notification_opt_in_yes?
        ClientMessagingService.send_system_text_message(
          client: @form.intake.client,
          body: I18n.t("messages.sms_opt_in")
        )
      end
    end
  end
end
