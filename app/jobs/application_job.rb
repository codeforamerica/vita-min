class ApplicationJob < ActiveJob::Base
  include ConsolidatedTraceHelper

  ## this should be within the body of a `with_raven_context` block for max effectiveness
  def ensure_zendesk_ticket_on(intake)
    unless intake.intake_ticket_id.present?
      raise ZendeskIntakeService::MissingTicketError,
            "missing intake_ticket_id. intake_id: #{intake.id}"
      # TODO: MissingTicketError might want to live somewhere else
    end
  end
end
