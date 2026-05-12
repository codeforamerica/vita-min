Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry_dsn)
  config.enabled_environments = %w(production staging demo)

  # Aggressively strip ALL client input while preserving error details
  config.before_send = lambda do |event, _hint|
    # Keep: exception class, message, stacktrace, timestamps
    # Remove: ALL request data, parameters, headers, cookies, user input

    if event.request
      # Keep only safe request metadata
      safe_request = {
        method: event.request[:method],
        # Strip path parameters and query strings for privacy
        url: event.request[:url]&.split('?')&.first&.gsub(/\/\d+/, '/:id'),
      }
      event.request = safe_request
    end

    # Remove all breadcrumbs that might contain user input
    event.breadcrumbs&.list&.clear

    # Remove user context
    event.user = {}

    # Remove extra context that might have been added
    event.extra&.clear

    # Remove tags that might contain user data
    event.tags&.delete_if { |key, _| ![:environment, :server_name, :ruby_version, :rails_version].include?(key.to_sym) }

    event
  end

  config.excluded_exceptions = Sentry::Configuration::IGNORE_DEFAULT + Sentry::Rails::IGNORE_DEFAULT + %w(
    ActionController::UnknownFormat
    ActionDispatch::RemoteIp::IpSpoofAttackError
    Puma::HttpParserError
  )
end
