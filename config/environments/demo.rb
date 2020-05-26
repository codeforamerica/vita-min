require_relative "./shared_deployment_config"

Rails.application.configure do
  config.i18n.available_locales = [:en]
  config.active_storage.service = :s3_demo

  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
