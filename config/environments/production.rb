require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  config.ctc_url = "https://getctc.org"
  config.gyr_url = "https://getyourrefund.org"
  ctc_email_from_domain = "getctc.org"
  gyr_email_from_domain = "getyourrefund.org"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = true

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "prod"
end
