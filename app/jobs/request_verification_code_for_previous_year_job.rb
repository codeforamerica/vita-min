class RequestVerificationCodeForPreviousYearJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end

  def perform(email_address: nil, locale:)
    VerificationCodeMailer.archived_intake_verification_code(to: email_address, locale: locale, verification_code: 'todo-generate-code').deliver_now
  end
end
