class CreateZendeskIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    return unless intake.intake_ticket_id.blank?

    with_raven_context(intake_context(intake)) do
      service = ZendeskIntakeService.new(intake)

      requester_id = service.assign_requester
      ticket = service.create_intake_ticket if requester_id # raises error if ticket creation fails

      if ticket
        diy_intakes = DiyIntake.where.not(email_address: nil).where(email_address: intake.email_address).filter { |i| i.ticket_id.present? }

        # append fill service notice to any related DIY tickets
        diy_intakes.each do |diy_intake|
          other_service = ZendeskDiyIntakeService.new(diy_intake)
          other_service.append_comment_to_ticket(
            ticket_id: diy_intake.ticket_id,
            comment: "This client has a GetYourRefund full service ticket: #{ticket.url}"
          )
        end
      end
    end
  end
end
