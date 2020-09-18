require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_demo

  config.action_mailer.default_options = { from: 'hello@mg-demo.getyourrefund-testing.org' }
  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
  # Custom config value read by DeviseMailer class
  config.devise_email_from = 'no-reply@mg-demo.getyourrefund-testing.org'
end
