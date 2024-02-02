require_relative "./shared_deployment_config"

Rails.application.configure do
  config.active_storage.service = :s3_heroku

  # HEROKU_PR_NUMBER variable is documented at https://devcenter.heroku.com/articles/github-integration-review-apps#injected-environment-variables
  gyr_hostname = "pr-#{ENV['HEROKU_PR_NUMBER']}.getyourrefund-testing.org"
  ctc_hostname = "ctc.#{gyr_hostname}"
  state_file_hostname = "statefile.#{gyr_hostname}"

  config.ctc_url = "https://#{ctc_hostname}"
  config.statefile_url = "https://#{state_file_hostname}"
  config.gyr_url = "https://#{gyr_hostname}"

  ctc_email_from_domain = "mg-demo-ctc.getyourrefund-testing.org"
  gyr_email_from_domain = "mg-demo.getyourrefund-testing.org"
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
  config.action_mailer.default_url_options = { host: config.gyr_url }
  config.action_mailer.asset_host = config.gyr_url
  config.hide_ctc = false

  Rails.application.default_url_options = config.action_mailer.default_url_options
  config.efile_environment = "test"
  config.google_login_enabled = (ENV['GOOGLE_LOGIN_ENABLED'] == 'true')

  # StateFile
  config.state_file_start_of_open_intake = Time.find_zone('America/New_York').parse('2024-01-01 7:59:59')
end
