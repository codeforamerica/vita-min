module Questions
  class ConsentController < QuestionsController
    include AnonymousIntakeConcern
    layout "intake"
    before_action :check_required_attributes

    def illustration_path; end

    def next_path
      current_intake.itin_applicant? && current_intake.has_duplicate? ? returning_client_questions_path : super
    end

    def after_update_success
      # early return if client is an itin applicant and has a duplicate, because we can't dupe check them properly til
      # they get here!
      return if current_intake.itin_applicant? && current_intake.has_duplicate?

      if current_intake.primary_consented_to_service_at.blank?
        current_intake.update(
          primary_consented_to_service_ip: request.remote_ip,
          primary_consented_to_service: "yes"
        )
      end

      GenerateRequiredConsentPdfJob.perform_later(current_intake)

      send_welcome_message

      # the vita partner the client was routed to has capacity
      unless current_intake.client.routing_method_at_capacity?
        InitialTaxReturnsService.new(intake: current_intake).create!
        GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
      end

      sign_in current_intake.client unless current_intake.client.routing_method_at_capacity?
    end

    private

    def check_required_attributes
      if current_intake.primary_ssn.blank?
        redirect_to Questions::TriagePersonalInfoController.to_path_helper
      end
    end

    def send_welcome_message
      @client = current_intake.client

      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: current_intake.client,
        message: AutomatedMessage::Welcome,
        locale: I18n.locale
      )
    end
  end
end
