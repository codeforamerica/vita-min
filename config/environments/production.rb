require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  config.action_mailer.default_options = { from: "hello@getyourrefund.org" }
  config.address_for_transactional_authentication_emails = 'no-reply@getyourrefund.org'
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  config.action_mailer.asset_host = "https://getyourrefund.org"

  config.offseason = false
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
