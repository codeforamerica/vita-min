require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.ctc_url = "https://ctc.staging.getyourrefund.org"
  config.gyr_url = "https://staging.getyourrefund.org"
  config.statefile_url = "https://staging.fileyourstatetaxes.org"
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
      statefile: "support@#{statefile_email_from_domain}"
    }
  }
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"

  # StateFile
  config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-01-01 7:59:59')

  # Keep GYR and FYST 'open' until the end of 2040 ^_^
  # use the session toggles if you want to emulate/test 'closed' behaviors
  # use the year "2040" to test what it looks like between these milestones
  the_earlier_future = Time.find_zone('America/New_York').parse('2039-12-31 23:59:59')
  the_further_future = Time.find_zone('America/New_York').parse('2040-12-31 23:59:59')
  config.end_of_intake = the_further_future
  config.state_file_end_of_new_intakes = the_earlier_future
  config.state_file_end_of_in_progress_intakes = the_further_future
end
