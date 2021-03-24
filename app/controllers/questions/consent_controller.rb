module Questions
  class ConsentController < AnonymousIntakeController
    layout "intake"

    def illustration_path; end

    def form_params
      super.merge(
        primary_consented_to_service_ip: request.remote_ip,
      )
    end

    def after_update_success
      sign_in current_intake.client
      current_intake.advance_tax_return_statuses_to("intake_in_progress")
      if current_intake.email_notification_opt_in_yes?
        body = I18n.t("messages.getting_started.email_body", preferred_name: current_intake.preferred_name, requested_docs_link: current_intake.requested_docs_token_link, locale: current_intake.locale, client_id: current_intake.client_id)
        subject = I18n.t("messages.getting_started.email_subject", locale: current_intake.locale)
        ClientMessagingService.send_system_email(current_intake.client, body, subject)
      end
      if current_intake.sms_notification_opt_in_yes?
        body = I18n.t("messages.getting_started.sms_body", preferred_name: current_intake.preferred_name, requested_docs_link: current_intake.requested_docs_token_link, locale: current_intake.locale, client_id: current_intake.client_id)
        ClientMessagingService.send_system_text_message(current_intake.client, body)
      end
      Intake14446PdfJob.perform_later(current_intake, "Consent Form 14446.pdf")
      IntakePdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
