 class ClientEmailVerificationRequestJob < ApplicationJob
  def perform(email_address:, locale:, visitor_id:)
    ClientLoginsService.request_email_verification(email_address: email_address, locale: locale, visitor_id: visitor_id)
  end
end
