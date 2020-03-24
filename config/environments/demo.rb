require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_demo

  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
end
