class ClientLoginRequestMailer < ApplicationMailer
  def client_login_email(login_link)
    @login_link = login_link
  end
end
