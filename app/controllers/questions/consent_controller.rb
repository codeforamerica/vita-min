module Questions
  class ConsentController < QuestionsController
    layout "application"

    def form_params
      super.merge(
        primary_consented_to_service_ip: request.remote_ip,
      )
    end

    def after_update_success
      # the 'if' following the next line is duplicated in CreateZendeskIntakeTicketJob#perform
      CreateZendeskIntakeTicketJob.perform_later(current_intake.id) if current_intake.intake_ticket_id.blank?
    end
  end
end
