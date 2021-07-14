require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.action_mailer.default_options = { from: 'hello@mg-staging.getyourrefund-testing.org' }
  config.address_for_transactional_authentication_emails = 'no-reply@mg-staging.getyourrefund-testing.org'
  config.ctc_url = "https://ctc.staging.getyourrefund.org"
  config.gyr_url = "https://staging.getyourrefund.org"
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = false
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
