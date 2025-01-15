class ArchivedIntakeEmailVerificationCodeJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end

  def perform(email_address:, locale:)
    ArchivedIntakeEmailVerificationCodeService.request_code(email_address: email_address, locale: locale)
  end
end
