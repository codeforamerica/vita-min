require_relative "./shared_deployment_config"

Rails.application.configure do
  config.i18n.available_locales = [:'en', :'es']
  config.active_storage.service = :s3_staging

  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
