class SendIntakePdfToZendeskJob < ApplicationJob
  include ConsolidatedTraceHelper
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    return if intake.intake_pdf_sent_to_zendesk

    # ensure setup has happened?
    service = ZendeskIntakeService.new(intake)

    # set up initial ticket if there was an initial failure
    service.assign_requester && service.assign_intake_ticket

    # this is somewhat redundant with the raise of the
    # MissingTicketIdError in ZendeskServiceHelper#append_multiple_files_to_tickets
    # if this was missing prior, we've attempted to create the appropriate
    if intake.intake_ticket_id.present?
      with_raven_context({ticket_id: intake.intake_ticket_id}) do
        begin
          output = service.send_preliminary_intake_and_consent_pdfs
          intake.update(intake_pdf_sent_to_zendesk: output)
        rescue ZendeskIntakeService::MissingTicketError
          trace_error('SendIntakePdfToZendeskJob: unable to find ticket with associated intake_ticket_id',
                      intake_context(intake))
        end
      end
      return
    end

    # if the intake has no intake ticket id, we fall through to the notification
    trace_error('SendIntakePdfToZendeskJob: missing intake_ticket_id on intake',
                intake_context(intake))
  end
end
