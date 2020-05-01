class CreateZendeskIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    return unless intake.intake_ticket_id.blank?
    with_raven_context({ticket_id: intake.intake_ticket_id}) do
      service = ZendeskIntakeService.new(intake)

      assign_requester(service, intake) &&
      assign_intake_ticket(service, intake)
    end
  end

  def assign_requester(service, intake)
    # if the requester has been assigned, return it.
    return intake.intake_ticket_requester_id if intake.intake_ticket_requester_id.present?

    # if not, attempt to create a requester and return it
    if requester_id = service.create_intake_ticket_requester
      intake.update(intake_ticket_requester_id: requester_id)
      return requester_id
    end

    # failing all else, that's likely noteworthy
    trace_error('ZendeskIntakeTicketJob failed to create a ticket requester',
                name: intake.preferred_name,
                email: intake.email_address,
                phone: intake.phone_number)
    return # ensure a nil return value
  end

  def assign_intake_ticket(service, intake)
    # if there's an intake ticket id, return it
    return intake.intake_ticket_id if intake.intake_ticket_id.present?

    # if not, attempt to create it
    if intake_ticket_id = service.create_intake_ticket
      intake.update(intake_ticket_id: intake_ticket_id)
      return intake_ticket_id
    end

    # failing all else, that's likely noteworthy
    trace_error('ZendeskIntakeTicketJob failed to create an intake ticket',
                name: intake.preferred_name,
                email: intake.email_address,
                phone: intake.phone_number)
    return # ensure a nil return value
  end
end
