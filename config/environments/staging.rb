require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_staging

  config.ctc_url = "https://ctc.staging.getyourrefund.org"
  config.gyr_url = "https://staging.getyourrefund.org"
  ctc_email_from_domain = "mg-staging-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-staging.getyourrefund-testing.org"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  config.action_mailer.default_url_options = { host: 'staging.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
end
