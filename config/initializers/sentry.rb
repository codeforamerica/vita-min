Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry_dsn)
  config.enabled_environments = %w(production staging demo)

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    # use Rails' parameter filter to sanitize the event
    filter.filter(event.to_hash)
  end

  config.excluded_exceptions = Sentry::Configuration::IGNORE_DEFAULT + Sentry::Rails::IGNORE_DEFAULT + %w(
    ActionController::UnknownFormat
    ActionDispatch::RemoteIp::IpSpoofAttackError
  )
end
