require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.action_mailer.default_options = { from: 'hello@mg-staging.getyourrefund-testing.org' }
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
  # Custom config value read by DeviseMailer class
  config.devise_email_from = 'no-reply@mg-staging.getyourrefund-testing.org'
end
