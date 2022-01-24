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

      # client has not yet been routed, or was previously determined to have been at capacity
      if current_intake.client.routing_method.blank? || current_intake.client.routing_method_at_capacity?
        routing_service = PartnerRoutingService.new(
          intake: current_intake,
          source_param: current_intake.source,
          zip_code: current_intake.zip_code,
        )
        current_intake.client.update(vita_partner: routing_service.determine_partner, routing_method: routing_service.routing_method)
      end
      
      # the vita partner the client was routed to has capacity
      unless current_intake.client.routing_method_at_capacity?
        tax_returns = []
        TaxReturn.filing_years.each do |year|
          tax_returns.push(TaxReturn.find_or_initialize_by(year: year, client: current_intake.client)) if current_intake.send("needs_help_#{year}") == "yes"
        end
        current_intake.client.tax_returns.replace(tax_returns)
        tax_returns.map { |tr| tr.advance_to(:intake_in_progress) }

        sign_in current_intake.client
        ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
          client: current_intake.client,
          message: AutomatedMessage::GettingStarted,
          locale: I18n.locale
        )
        GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
      end
    end
  end
end
