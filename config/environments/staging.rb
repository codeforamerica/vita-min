require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = {
    api_key: EnvironmentCredentials.dig(:mailgun, :api_key),
    domain: EnvironmentCredentials.dig(:mailgun, :domain)
  }
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
