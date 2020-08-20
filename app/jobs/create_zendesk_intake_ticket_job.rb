class CreateZendeskIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper
  include UpdateIntakeEnqueuedTicketCreationMixin

  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    return unless intake.intake_ticket_id.blank?

    with_raven_context(intake_context(intake)) do
      service = ZendeskIntakeService.new(intake)

      service.assign_requester
      ticket = service.create_intake_ticket

      # append full service notice to any related tickets
      if ticket
        diy_intake_ticket_ids = DiyIntake.where.not(email_address: nil).where.not(ticket_id: nil).where(email_address: intake.email_address).pluck(:ticket_id)
        eip_intake_ticket_ids = Intake.where.not(email_address: nil).where.not(intake_ticket_id: nil).where(email_address: intake.email_address, eip_only: true).pluck(:intake_ticket_id)
        (diy_intake_ticket_ids + eip_intake_ticket_ids).each do |ticket_id|
          service.append_comment_to_ticket(
            ticket_id: ticket_id,
            comment: "This client has a GetYourRefund full service ticket: #{service.ticket_url(ticket.id)}"
          )
        end
      end
    end
  end
end
