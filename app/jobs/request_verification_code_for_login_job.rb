class RequestVerificationCodeForLoginJob < ApplicationJob
  def perform(email_address: nil, phone_number: nil, locale:, visitor_id:, service_type:)
    client_login_service = ClientLoginService.new(service_type)
    if email_address.present?
      if client_login_service.can_login_by_email_verification?(email_address)
        EmailVerificationCodeService.request_code(
          email_address: email_address,
          locale: locale,
          visitor_id: visitor_id,
          service_type: service_type
        )
      else
        VerificationCodeMailer.no_match_found(
          to: email_address,
          locale: locale,
          service_type: service_type
        ).deliver_now
      end
    end

    if phone_number.present?
      if client_login_service.can_login_by_sms_verification?(phone_number)
        TextMessageVerificationCodeService.request_code(
          phone_number: phone_number,
          locale: locale,
          visitor_id: visitor_id,
          service_type: service_type
        )
      else
        service_name = service_type.to_s.match?(/ctc/) ? "GetCTC" : "GetYourRefund"
        TwilioService.send_text_message(
          to: phone_number,
          body: I18n.t("verification_code_sms.no_match", service_name: service_name, locale: locale)
        )
      end
    end
  end
end