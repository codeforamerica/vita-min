class RequestVerificationCodeTextMessageJob < ApplicationJob 
  def perform(sms_phone_number:, locale:, visitor_id:, verification_type: :gyr_login, client_id: nil)
    TextMessageVerificationCodeService.request_code(
      phone_number: sms_phone_number,
      locale: locale,
      visitor_id: visitor_id,
      verification_type: verification_type,
      client_id: client_id
    )
 end
end
