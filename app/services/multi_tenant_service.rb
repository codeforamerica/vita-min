class MultiTenantService
  attr_accessor :service_type

  SERVICE_TYPES = [:gyr, :ctc, :statefile, :statefile_az, :statefile_ny]

  def initialize(service_type)
    @service_type = service_type.to_sym
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? @service_type
  end

  def url(locale: :en)
    base =
      case service_type
      when :ctc then Rails.configuration.ctc_url
      when :gyr then Rails.configuration.gyr_url
      when :statefile then Rails.configuration.statefile_url
      end
    [base, locale].compact.join("/")
  end

  def host
    base =
      case service_type
      when :ctc
        Rails.configuration.ctc_url
      when :gyr
        Rails.configuration.gyr_url
      when :statefile
        Rails.configuration.statefile_url
      end
    URI(base).hostname
  end

  def service_name
    case service_type
    when :ctc then "GetCTC"
    when :gyr then "GetYourRefund"
    when :statefile then "CFA State File"
    end
  end

  def intake_model
    case service_type
    when :ctc then Intake::CtcIntake
    when :gyr then Intake::GyrIntake
    when :statefile_az then StateFileAzIntake
    when :statefile_ny then StateFileNyIntake
    when :statefile
      raise StandardError, "No intake model for generic 'statefile' service type"
    end
  end

  def email_logo
    case service_type
    when :ctc then File.read(Rails.root.join('app/assets/images/get-ctc-logo.png'))
    when :gyr then File.read(Rails.root.join('app/assets/images/logo.png'))
    when :statefile then File.read(Rails.root.join('app/assets/images/logo.png')) # TODO(state-file): email logo for state file
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
    case service_type
    when :ctc then Rails.configuration.ctc_current_tax_year
    when :gyr then Rails.configuration.gyr_current_tax_year
    when :statefile then Rails.configuration.statefile_current_tax_year
    end
  end

  def end_of_current_tax_year
    DateTime.new(current_tax_year).end_of_year
  end

  def prior_tax_year
    current_tax_year - 1
  end

  def filing_years
    if service_type == :ctc || service_type == :state_file
      [current_tax_year]
    else
      ((current_tax_year - 3)..current_tax_year).to_a.reverse.freeze
    end
  end

  def backtax_years
    filing_years.without(current_tax_year)
  end

  class << self
    def ctc
      new(:ctc)
    end

    def gyr
      new(:gyr)
    end

    def statefile
      new(:statefile)
    end
  end
end
