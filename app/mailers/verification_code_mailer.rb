class VerificationCodeMailer < ApplicationMailer
  def with_code
    service = MultiTenantService.new(params[:service_type])
    @service_name = service.service_name
    @locale = params[:locale]
    @subject = I18n.t("messages.default_subject_with_service_name", service_name: @service_name, locale: @locale)
    @verification_code = params[:verification_code]
    mail(to: params[:to], subject: @subject)
  end

  def no_match_found(to:, locale:, service_type:)
    @locale = locale
    service = MultiTenantService.new(service_type)
    @subject = I18n.t("verification_code_mailer.no_match.subject", service_name: service.service_name, url: service.url(locale: locale), locale: @locale)
    mail(to: to, subject: @subject)
  end
end
