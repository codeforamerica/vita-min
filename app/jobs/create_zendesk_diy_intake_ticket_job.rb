class CreateZendeskDiyIntakeTicketJob < ZendeskJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(diy_intake_id)
    diy_intake = DiyIntake.find(diy_intake_id)
    return unless diy_intake.ticket_id.blank?

    with_raven_context(diy_intake_context(diy_intake)) do
      service = ZendeskDiyIntakeService.new(diy_intake)

      service.assign_requester
      ticket = service.create_diy_intake_ticket # raises error if ticket not created

      if ticket
        intakes = Intake.where.not(email_address: nil).where(email_address: diy_intake.email_address).filter { |i| i.intake_ticket_id.present? }

        # append DIY notice to any related Full Service tickets
        intakes.each do |intake|
          service.append_comment_to_ticket(
            ticket_id: intake.intake_ticket_id,
            comment: "This client has requested a TaxSlayer DIY link from GetYourRefund.org",
            skip_if_closed: true,
          )
        end
      end
    end
  end
end
