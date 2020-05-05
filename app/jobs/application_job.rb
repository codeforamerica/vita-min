class ApplicationJob < ActiveJob::Base
  include ConsolidatedTraceHelper

  retry_on ZendeskIntakeService::MissingTicketError, wait: 1.minute

  ## this should be within the body of a `with_raven_context` block for max effectiveness
  def ensure_zendesk_ticket_on(intake)
    unless intake.intake_ticket_id.present?
      CreateZendeskIntakeTicketJob.perform_later(intake.id)
      raise ZendeskIntakeService::MissingTicketError,
            "missing intake_ticket_id. dispatching ticket creation and retrying in 1 minute"
      # TODO: MissingTicketError might want to live somewhere else
    end
  end
end
