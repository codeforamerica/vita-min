require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  config.action_mailer.default_options = { from: "hello@getyourrefund.org" }
  config.address_for_transactional_authentication_emails = 'no-reply@getyourrefund.org'
  config.ctc_url = "https://getctc.org"
  config.gyr_url = "https://getyourrefund.org"
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = true

  Rails.application.default_url_options = config.action_mailer.default_url_options
end
