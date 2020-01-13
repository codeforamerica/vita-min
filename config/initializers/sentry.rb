Raven.configure do |config|
  config.dsn = Rails.application.credentials.dig(Rails.env.to_sym, :sentry_dsn)
  config.environments = %w(production staging demo)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end