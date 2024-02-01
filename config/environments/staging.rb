require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.ctc_url = "https://ctc.staging.getyourrefund.org"
  config.statefile_url = "https://staging.fileyourstatetaxes.org"
  config.gyr_url = "https://staging.getyourrefund.org"
  ctc_email_from_domain = "mg-staging-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-staging.getyourrefund-testing.org"
  statefile_email_from_domain = "mg-staging-statefile.getyourrefund-testing.org"
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

end
