class CreateZendeskIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    return unless intake.intake_ticket_id.blank?
    with_raven_context(intake_context(intake)) do
      service = ZendeskIntakeService.new(intake)

      requester_id = service.assign_requester
      # TODO: it appears that create_intake_ticket may return a ticket rather than a ticket id, though it claims to return a ticket id
      ticket_id = service.create_intake_ticket if requester_id

      if ticket_id
        diy_intakes = DiyIntake.where.not(email_address: nil).where(email_address: intake.email_address).filter { |i| i.ticket_id.present? }
        diy_intakes.each do |diy_intake|
          # append notice to DIY tickets
          ticket = service.find_ticket(ticket_id)
          if ticket
            service.append_comment_to_ticket(
              ticket_id: diy_intake.ticket_id,
              comment: "This client has a GetYourRefund full service ticket: #{ticket.url}"
            )
          end
        end
      end
    end
  end
end
