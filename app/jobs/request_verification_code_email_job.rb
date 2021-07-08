class RequestVerificationCodeEmailJob < ApplicationJob
  def perform(email_address: , locale: , visitor_id: , client_id: nil, service_type:)
    EmailVerificationCodeService.request_code(
      email_address: email_address,
      locale: locale,
      visitor_id: visitor_id,
      client_id: client_id,
      service_type: service_type
    )
  end
end