module Questions
  class ConsentController < QuestionsController
    include AnonymousIntakeConcern
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
        email_body: I18n.t("messages.getting_started.email_body"),
        subject: I18n.t("messages.getting_started.email_subject"),
        sms_body: I18n.t("messages.getting_started.sms_body"),
        locale: I18n.locale
      )
      Intake14446PdfJob.perform_later(current_intake, "Consent Form 14446.pdf")
      IntakePdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
