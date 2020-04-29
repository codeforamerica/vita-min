class CreateZendeskIntakeTicketJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    with_raven_context({ticket_id: intake.intake_ticket_id}) do
      if intake.intake_ticket_id.blank?
        service = ZendeskIntakeService.new(intake)
        if intake.intake_ticket_requester_id.blank?
          intake.update(intake_ticket_requester_id: service.create_intake_ticket_requester)
        end
        intake.update(intake_ticket_id: service.create_intake_ticket)
      end
    end
  end
end
