class DeviseMailer < Devise::Mailer
  default from: Rails.configuration.email_from[:noreply][:gyr]
end
