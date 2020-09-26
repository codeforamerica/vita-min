require_relative "./shared_deployment_config"

Rails.application.configure do
  # Set cache control headers
  config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=31536000'
  }

  config.active_storage.service = :s3_prod

  config.action_mailer.default_options = { from: "hello@getyourrefund.org" }
  config.address_for_transactional_authentication_emails = 'no-reply@getyourrefund.org'
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  Rails.application.default_url_options = config.action_mailer.default_url_options
end
