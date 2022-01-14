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
      GenerateRequiredConsentPdfJob.perform_later(current_intake)

      unless current_intake.client.routing_method.present?
        routing_service = PartnerRoutingService.new(
          intake: current_intake,
          source_param: current_intake.source,
          zip_code: current_intake.zip_code,
        )
        current_intake.client.update(vita_partner: routing_service.determine_partner, routing_method: routing_service.routing_method)
      end

      unless current_intake.client.routing_method_at_capacity?
        sign_in current_intake.client
        ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
          client: current_intake.client,
          message: AutomatedMessage::GettingStarted,
          locale: I18n.locale
        )
        current_intake.tax_returns.each { |tr| tr.advance_to(:intake_in_progress) }
        GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
      end
    end
  end
end
