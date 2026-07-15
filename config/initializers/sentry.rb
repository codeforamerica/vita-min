Sentry.init do |config|
  config.dsn = EnvironmentalCredentials['SENTRY_DSN']
  config.enabled_environments = %w(production staging demo)

  config.before_send = lambda do |event, _hint|

    if event.request
      safe_request = {
        method: event.request[:method],
        url: event.request[:url]&.split('?')&.first&.gsub(/\/\d+/, '/:id'),
      }
      event.request = safe_request
    end

    event.breadcrumbs = Sentry::BreadcrumbBuffer.new(0) if event.breadcrumbs

    event.user = {}

    event.extra&.clear

    event.tags&.delete_if { |key, _| ![:environment, :server_name, :ruby_version, :rails_version].include?(key.to_sym) }

    event
  end

  config.excluded_exceptions = Sentry::Configuration::IGNORE_DEFAULT + Sentry::Rails::IGNORE_DEFAULT + %w(
    ActionController::UnknownFormat
    ActionDispatch::RemoteIp::IpSpoofAttackError
    Puma::HttpParserError
  )
end
