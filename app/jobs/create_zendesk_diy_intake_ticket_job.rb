class CreateZendeskDiyIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(diy_intake_id)
    diy_intake = DiyIntake.find(diy_intake_id)

    with_raven_context(diy_intake_context(diy_intake)) do
      service = ZendeskDiyIntakeService.new(diy_intake)

      service.assign_requester
      ticket = service.create_diy_intake_ticket # will raise an exception if no ticket as of 1.0.9

      if ticket
        intakes = Intake.where(email_address: diy_intake.email_address).filter { |i| i.zendesk_ticket_id.present? }
        intakes.each do |intake|
          # append DIY notice to Full Service ticket
          other_service = ZendeskIntakeService.new(intake)
          other_service.append_comment_to_ticket(ticket_id: intake.zendesk_ticket_id,
                                                 comment: "This client has requested a TaxSlayer DIY link from GetYourRefund.org")

          # append Full Service notice to DIY Ticket
          other_ticket = other_service.find_ticket(intake.zendesk_ticket_id)
          service.append_comment_to_ticket(ticket_id: ticket.id,
                                           comment: "This client has a GetYourRefund full service ticket: #{other_ticket.url}")
        end
      else
        # ticket wasn't created, an exception should already have happened and the
        # job cancelled.
      end
    end
  end
end
