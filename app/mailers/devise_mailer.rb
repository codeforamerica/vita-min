class DeviseMailer < Devise::Mailer
  default from: Rails.configuration.devise_email_from
end
