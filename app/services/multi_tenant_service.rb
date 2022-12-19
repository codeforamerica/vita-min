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

  def host
    base = service_type == :ctc ? Rails.configuration.ctc_url : Rails.configuration.gyr_url
    URI(base).hostname
  end

  def service_name
    case service_type
    when :ctc then "GetCTC"
    when :gyr then "GetYourRefund"
    end
  end

  def email_logo
    case service_type
    when :ctc then File.read(Rails.root.join('app/assets/images/get-ctc-logo.png'))
    when :gyr then File.read(Rails.root.join('app/assets/images/logo.png'))
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

  def current_tax_year
    if service_type == :ctc
      Rails.configuration.ctc_current_tax_year
    else
      Rails.configuration.gyr_current_tax_year
    end
  end

  def prior_tax_year
    current_tax_year - 1
  end

  def filing_years
    if service_type == :ctc
      [current_tax_year]
    else
      ((current_tax_year - 3)..current_tax_year).to_a.reverse.freeze
    end
  end

  def backtax_years
    filing_years.without(current_tax_year)
  end

  def current_product_year
    2022
  end
end
