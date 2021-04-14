require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.action_mailer.default_options = { from: 'hello@mg-staging.getyourrefund-testing.org' }
  config.address_for_transactional_authentication_emails = 'no-reply@mg-staging.getyourrefund-testing.org'
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  config.action_mailer.asset_host = "https://staging.getyourrefund.org"

  config.offseason = false
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
