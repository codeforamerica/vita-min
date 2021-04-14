class ClientLoginRequestMailer < ApplicationMailer
  def login_email
    @locale = params[:locale]
    @subject = I18n.t("messages.default_subject", locale: @locale)
    @verification_code = params[:verification_code]
    mail(to: params[:to], subject: @subject)
  end

  def no_match_found
    @locale = params[:locale]
    @subject = I18n.t("client_login_request_mailer.no_match.subject", locale: @locale)
    mail(to: params[:to], subject: @subject)
  end
end
