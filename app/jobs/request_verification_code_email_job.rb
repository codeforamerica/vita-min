class RequestVerificationCodeEmailJob < ApplicationJob
  def perform(email_address: , locale: , visitor_id: , client_id: nil, verification_type: :gyr_login)
    EmailVerificationCodeService.request_code(
      email_address: email_address,
      locale: locale,
      visitor_id: visitor_id,
      client_id: client_id,
      verification_type: verification_type
    )
  end
end