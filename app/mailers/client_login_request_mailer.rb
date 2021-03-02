class ClientLoginRequestMailer < ApplicationMailer
  def login_email
    @locale = params[:locale] || I18n.locale
    @token_url = portal_client_login_url(locale: @locale, id: params[:raw_token])
    mail(to: params[:to], subject: I18n.t("messages.default_subject", locale: @locale))
  end

  def no_match_found
    @locale = params[:locale] || I18n.locale
    mail(to: params[:to], subject: I18n.t("client_login_request_mailer.no_match.subject", locale: @locale))
  end
end
