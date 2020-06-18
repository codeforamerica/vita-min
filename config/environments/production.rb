require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
