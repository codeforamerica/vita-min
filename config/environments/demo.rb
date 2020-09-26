require_relative "./shared_deployment_config"

Rails.application.configure do
  config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=31536000'
  }
  config.active_storage.service = :s3_demo

  config.action_mailer.default_options = { from: 'hello@mg-demo.getyourrefund-testing.org' }
  config.address_for_transactional_authentication_emails = 'no-reply@mg-demo.getyourrefund-testing.org'
  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
