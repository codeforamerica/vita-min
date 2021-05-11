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
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        email_body: I18n.t("messages.getting_started.email_body", preferred_name: current_intake.preferred_name, portal_login_url: new_portal_client_login_url(locale: current_intake.locale), locale: current_intake.locale, client_id: current_intake.client_id),
        subject: I18n.t("messages.getting_started.email_subject", locale: current_intake.locale),
        sms_body: I18n.t("messages.getting_started.sms_body", preferred_name: current_intake.preferred_name, portal_login_url: new_portal_client_login_url(locale: current_intake.locale), locale: current_intake.locale, client_id: current_intake.client_id)
      )
      Intake14446PdfJob.perform_later(current_intake, "Consent Form 14446.pdf")
      IntakePdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
