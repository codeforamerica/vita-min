require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_prod

  config.ctc_url = "https://www.getctc.org"
  config.gyr_url = "https://www.getyourrefund.org"
  config.statefile_url = "https://www.fileyourstatetaxes.org"
  ctc_email_from_domain = "getctc.org"
  gyr_email_from_domain = "getyourrefund.org"
  statefile_email_from_domain = "fileyourstatetaxes.org"
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
  config.action_mailer.default_url_options = { host: 'www.getyourrefund.org' }
  config.action_mailer.asset_host = config.gyr_url
  config.hide_ctc = true

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "prod"

  config.intercom_app_id = "p1hu33n8"
  config.intercom_app_id_statefile = "p8cvpjy8"
end
