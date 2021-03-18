class ClientLoginRequestMailer < ApplicationMailer
  def login_email
    @locale = params[:locale]
    @verification_code = params[:verification_code]
    mail(to: params[:to], subject: I18n.t("messages.default_subject", locale: @locale))
  end

  def no_match_found
    @locale = params[:locale]
    mail(to: params[:to], subject: I18n.t("client_login_request_mailer.no_match.subject", locale: @locale))
  end
end
