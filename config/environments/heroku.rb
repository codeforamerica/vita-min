require Rails.root.join('config/environments/demo')

Rails.application.configure do
  # TODO: have an S3 bucket
  config.active_storage.service = :local

  # HEROKU_APP_NAME variable is documented at https://devcenter.heroku.com/articles/dyno-metadata
  heroku_app_name = ENV["HEROKU_APP_NAME"]
  pr_number = heroku_app_name.match(/.*(pr-\d+)/).captures.first
  gyr_hostname = "#{pr_number}.getyourrefund-testing.org"
  ctc_hostname = "ctc.#{gyr_hostname}"

  config.gyr_url = "https://#{gyr_hostname}"
  config.ctc_url = "https://#{ctc_hostname}"

  ctc_email_from_domain = "mg-demo-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-demo.getyourrefund-testing.org"
  config.email_from = {
    default: {ctc: "hello@#{ctc_email_from_domain}", gyr: "hello@#{gyr_email_from_domain}"},
    noreply: {ctc: "no-reply@#{ctc_email_from_domain}", gyr: "no-reply@#{gyr_email_from_domain}"}
  }
  config.action_mailer.default_url_options = { host: config.gyr_url }
  config.action_mailer.asset_host = config.gyr_url
  config.offseason = false
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"
end
