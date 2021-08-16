class MultiTenantService
  attr_accessor :service_type

  SERVICE_TYPES = [:gyr, :ctc]
  def initialize(service_type)
    @service_type = service_type.to_sym
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? @service_type
  end

  def url(locale: :en)
    base = service_type == :ctc ? Rails.configuration.ctc_url : Rails.configuration.gyr_url
    [base, locale].compact.join("/")
  end

  def service_name
    case service_type
    when :ctc then "GetCTC"
    when :gyr then "GetYourRefund"
    end
  end

  def default_email
    Rails.configuration.email_from[:default][service_type]
  end

  def noreply_email
    Rails.configuration.email_from[:noreply][service_type]
  end

  def delivery_method_options
    if service_type == :ctc && EnvironmentCredentials.dig(:mailgun, :ctc_api_key)
      {
        api_key: EnvironmentCredentials.dig(:mailgun, :ctc_api_key),
        domain: EnvironmentCredentials.dig(:mailgun, :ctc_domain)
      }
    else
      Rails.configuration.action_mailer.mailgun_settings
    end
  end
end
