Recaptcha.configure do |config|
  config.site_key = Rails.env.test? ? "test_key" : EnvironmentCredentials['RECAPTCHA_SITE_KEY']
  config.secret_key = Rails.env.test? ? "test_key" : EnvironmentCredentials['RECAPTCHA_SECRET_KEY']
end
