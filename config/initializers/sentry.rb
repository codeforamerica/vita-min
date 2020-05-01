Raven.configure do |config|
  config.dsn = Rails.application.credentials.dig(Rails.env.to_sym, :sentry_dsn)
  config.environments = %w(production staging demo development)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT + %w(
    ActionController::UnknownFormat
  )
end
