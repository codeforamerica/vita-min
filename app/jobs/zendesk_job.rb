class ZendeskJob < ActiveJob::Base
  include ConsolidatedTraceHelper

  ## this should be within the body of a `with_raven_context` block for max effectiveness
  def ensure_zendesk_ticket_on(intake)
    unless intake.intake_ticket_id.present?
      raise ZendeskIntakeService::MissingTicketError,
            "missing intake_ticket_id. intake_id: #{intake.id}"
      # TODO: MissingTicketError might want to live somewhere else
    end
  end

  # Specify `retry_on` so that retries occur. This is required based on manual testing.
  # Exponentially-longer wait with 5 attempts results in a max wait of about 10 minutes.
  # https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
  retry_on StandardError, wait: :exponentially_longer

  # In case of any error, try again a few times. This will catch transient Zendesk
  # outages as well as any other crashes. The "other" crashes are often the result of
  # *other* jobs needing to be retried. After those jobs retry, hopefully all will heal.
  #
  # This overrides `config/initializers/delayed_job.rb`'s default max_attempts = 1.
  def max_attempts
    5
  end
end
