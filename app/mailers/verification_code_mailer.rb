class VerificationCodeMailer < ApplicationMailer
  def with_code
    service = MultiTenantService.new(params[:service_type])
    @service_name = service.service_name
    @service_type = service.service_type
    @locale = params[:locale]
    @verification_code = params[:verification_code]
    attachments.inline['logo.png'] = service.email_logo
    @subject = if @service_type == :statefile
                 I18n.t('messages.verification_code_subject_with_service_name', service_name: @service_name, locale: @locale)
               else
                 I18n.t('messages.default_subject_with_service_name', service_name: @service_name, locale: @locale)
               end
    mail(to: params[:to], subject: @subject, from: service.noreply_email, delivery_method_options: service.delivery_method_options)
  end

  def no_match_found(to:, locale:, service_type:)
    @locale = locale
    service = MultiTenantService.new(service_type)
    @service_name = service.service_name
    @service_type = service.service_type
    @url = service.url(locale: locale)
    @subject = I18n.t("verification_code_mailer.no_match.subject", service_name: @service_name, url: service.url(locale: locale), locale: @locale)
    attachments.inline['logo.png'] = service.email_logo
    mail(to: to, subject: @subject, from: service.noreply_email, delivery_method_options: service.delivery_method_options)
  end
end
