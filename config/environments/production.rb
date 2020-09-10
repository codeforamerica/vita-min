require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  # Need to configure `from` address in production. Omitting configuration until that is ready.
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
