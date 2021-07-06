 class ClientTextMessageVerificationRequestJob < ApplicationJob
  def perform(sms_phone_number:, locale:, visitor_id:)
    ClientLoginsService.request_text_message_verification(
      sms_phone_number: sms_phone_number,
      locale: locale,
      visitor_id: visitor_id
    )
  end
end
