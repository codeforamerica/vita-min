class DeviseMailer < Devise::Mailer
  default from: Rails.configuration.address_for_transactional_authentication_emails
end
