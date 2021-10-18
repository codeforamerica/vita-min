class RequestVerificationCodeForLoginJob < ApplicationJob
  def perform(email_address: nil, phone_number: nil, locale:, visitor_id:, service_type:)
    client_login_service = ClientLoginService.new(service_type)
    multi_tenant_service = MultiTenantService.new(service_type)
    if email_address.present?
      if client_login_service.can_login_by_email_verification?(email_address)
        EmailVerificationCodeService.request_code(
          email_address: email_address,
          locale: locale,
          visitor_id: visitor_id,
          service_type: multi_tenant_service.service_type
        )
      else
        VerificationCodeMailer.no_match_found(
          to: email_address,
          locale: locale,
          service_type: multi_tenant_service.service_type,
        ).deliver_now
      end
    end

    if phone_number.present?
      if client_login_service.can_login_by_sms_verification?(phone_number)
        TextMessageVerificationCodeService.request_code(
          phone_number: phone_number,
          locale: locale,
          visitor_id: visitor_id,
          service_type: multi_tenant_service.service_type
        )
      else
        service_name = multi_tenant_service.service_name
        url = multi_tenant_service.url(locale: locale)
        body = service_name == "GetCTC" ? I18n.t("verification_code_sms.no_match_ctc", url: url, locale: locale) : I18n.t("verification_code_sms.no_match_gyr", url: url, locale: locale)
        TwilioService.send_text_message(
          to: phone_number,
          body: body
        )
      end
    end
  end
end