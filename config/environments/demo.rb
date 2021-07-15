require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_demo

  config.action_mailer.default_options = { from: 'hello@mg-demo.getyourrefund-testing.org' }
  config.address_for_transactional_authentication_emails = 'no-reply@mg-demo.getyourrefund-testing.org'
  config.ctc_url = "https://ctc.demo.getyourrefund.org"
  config.gyr_url = "https://demo.getyourrefund.org"
  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
end
