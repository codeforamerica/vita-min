class RequestVerificationCodeForLoginJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end

  def perform(email_address: nil, phone_number: nil, locale:, visitor_id:, service_type:)
    client_login_service = ClientLoginService.new(service_type)
    multi_tenant_service = MultiTenantService.new(service_type)
    if email_address.present?
      if client_login_service.can_login_by_email_verification?(email_address)
        EmailVerificationCodeService.request_code(
          email_address: email_address,
          locale: locale,
          visitor_id: visitor_id,
          service_type: multi_tenant_service.service_type_or_parent
        )
      else
        VerificationCodeMailer.no_match_found(
          to: email_address,
          locale: locale,
          service_type: multi_tenant_service.service_type_or_parent,
        ).deliver_now
      end
    end

    if phone_number.present?
      if client_login_service.can_login_by_sms_verification?(phone_number)
        TextMessageVerificationCodeService.request_code(
          phone_number: phone_number,
          locale: locale,
          visitor_id: visitor_id,
          service_type: multi_tenant_service.service_type_or_parent
        )
      else
        url = multi_tenant_service.url(locale: locale)
        body = case service_type
               when :ctc
                 I18n.t("verification_code_sms.no_match_ctc", url: url, locale: locale)
               when :gyr
                 I18n.t("verification_code_sms.no_match_gyr", url: url, locale: locale)
               when :statefile_az, :statefile_ny
                 I18n.t("state_file.intake_logins.no_match_sms", url: url, locale: locale)
               end
        TwilioService.send_text_message(
          to: phone_number,
          body: body
        )
      end
    end
  end
end