require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_demo

  config.ctc_url = "https://ctc.demo.getyourrefund.org"
  config.gyr_url = "https://demo.getyourrefund.org"
  ctc_email_from_domain = "mg-demo-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-demo.getyourrefund-testing.org"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"
  # At the moment on demo, we want intake to operate even if it's before the production launch.
  config.start_of_unique_links_only_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-01 00:00:00')
  config.start_of_open_intake = Time.find_zone('America/Los_Angeles').parse('2022-01-01 00:00:00')
end
