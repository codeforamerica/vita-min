class VerificationCodeMailer < ApplicationMailer
  def with_code
    @verification_type = params[:verification_type]
    @service_name = @verification_type.present? && @verification_type.match?(/ctc/) ? "GetCTC" : "GetYourRefund"
    @locale = params[:locale]
    @subject = I18n.t("messages.default_subject_with_service_name", service_name: @service_name, locale: @locale)
    @verification_code = params[:verification_code]
    mail(to: params[:to], subject: @subject)
  end

  def no_match_found
    @locale = params[:locale]
    @subject = I18n.t("verification_code_mailer.no_match.subject", locale: @locale)
    mail(to: params[:to], subject: @subject)
  end
end
