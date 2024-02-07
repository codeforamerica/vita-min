require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_demo

  config.ctc_url = "https://ctc.demo.getyourrefund.org"
  config.gyr_url = "https://demo.getyourrefund.org"
  config.statefile_url = "https://demo.fileyourstatetaxes.org"
  gyr_email_from_domain = "mg-demo.getyourrefund-testing.org"
  ctc_email_from_domain = "mg-demo-ctc.getyourrefund-testing.org"
  statefile_email_from_domain = "mg-demo-statefile.getyourrefund-testing.org"
  config.email_from = {
    default: {
      ctc: "hello@#{ctc_email_from_domain}",
      gyr: "hello@#{gyr_email_from_domain}",
      statefile: "hello@#{statefile_email_from_domain}"
    },
    noreply: {
      ctc: "no-reply@#{ctc_email_from_domain}",
      gyr: "no-reply@#{gyr_email_from_domain}",
      statefile: "no-reply@#{statefile_email_from_domain}"
    },
    support: {
      ctc: "support@#{ctc_email_from_domain}",
      gyr: "support@#{gyr_email_from_domain}",
      statefile: "help@#{statefile_email_from_domain}"
    }
  }
  config.action_mailer.default_url_options = { host: 'demo.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"

  # CTC
  config.ctc_soft_launch = Time.find_zone("America/New_York").parse("2022-03-01 09:00:00")
  config.ctc_full_launch = Time.find_zone("America/New_York").parse("2022-04-01 09:00:00")

  # StateFile
  config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-02-07 13:35:00')
end
