 class ClientTextMessageVerificationRequestJob < ApplicationJob
  def perform(sms_phone_number:, locale:, visitor_id:, verification_type: :gyr_login)
    TextMessageVerificationCodeService.request_code(
      sms_phone_number: sms_phone_number,
      locale: locale,
      visitor_id: visitor_id,
      verification_type: verification_type
    )
  end
end
