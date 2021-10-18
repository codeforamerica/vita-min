require Rails.root.join('config/environments/demo')

Rails.application.configure do
  # TODO: have an S3 bucket
  config.active_storage.service = :local

  heroku_host = "#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
  heroku_url = "https://#{heroku_host}"
  config.ctc_url = heroku_url.sub("gyr-", "ctc-")
  config.gyr_url = heroku_url.sub("ctc-", "gyr-")

  ctc_email_from_domain = "mg-staging-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-staging.getyourrefund-testing.org"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  config.action_mailer.default_url_options = { host: heroku_host }
  config.action_mailer.asset_host = heroku_url
  config.offseason = false
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"
end
