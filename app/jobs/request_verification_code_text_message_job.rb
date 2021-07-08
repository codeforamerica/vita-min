class RequestVerificationCodeTextMessageJob < ApplicationJob 
  def perform(phone_number:, locale:, visitor_id:, service_type:, client_id: nil)
    TextMessageVerificationCodeService.request_code(
      phone_number: phone_number,
      locale: locale,
      visitor_id: visitor_id,
      service_type: service_type,
      client_id: client_id
    )
 end
end
