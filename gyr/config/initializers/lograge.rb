Rails.application.configure do
  # Lograge config
  config.lograge.enabled = true

  # This specifies to log in JSON format
  config.lograge.formatter = Lograge::Formatters::Raw.new

  ## Disables log coloration
  config.colorize_logging = false

  # Log to the same place as Rails logs
  config.lograge.logger = Rails.logger

  # This is useful if you want to log query parameters
  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params]&.reject { |k| %w(controller action).include? k },
      request_details: event.payload[:request_details],
      level: event.payload[:level],
    }
  end
end
