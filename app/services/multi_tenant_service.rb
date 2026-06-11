class MultiTenantService
  include Rails.application.routes.url_helpers
  attr_accessor :service_type

  SERVICE_TYPES = [:gyr, :ctc, :statefile]

  def initialize(service_type)
    @service_type = service_type.to_sym
    raise(ArgumentError, "Unsupported service_type: #{service_type}") unless SERVICE_TYPES.include? @service_type
  end

  def url(locale: :en)
    case service_type
    when :ctc then [Rails.configuration.ctc_url, locale].compact.join("/")
    when :gyr then [Rails.configuration.gyr_url, locale].compact.join("/")
    when :statefile then [Rails.configuration.statefile_url, locale].compact.join("/")
    end
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
    when :statefile then "FileYourStateTaxes"
    end
  end

  def intake_model
    case service_type
    when :ctc then Intake::CtcIntake
    when :gyr then Intake::GyrIntake
    when :statefile
      raise StandardError, "Get intake model from StateFile::StateInformationService for statefile"
    end
  end

  def email_logo
    case service_type
    when :ctc then File.read(Rails.root.join('app/assets/images/get-ctc-logo.png'))
    when :gyr then File.read(Rails.root.join('app/assets/images/logo.png'))
    when :statefile then File.read(Rails.root.join('app/assets/images/FYST_email_logo.png'))
    end
  end

  def default_email
    Rails.configuration.email_from[:default][service_type]
  end

  def noreply_email
    Rails.configuration.email_from[:noreply][service_type]
  end

  def support_email
    Rails.configuration.email_from[:support][service_type]
  end

  def delivery_method_options
    if service_type == :ctc && (ENV["MAILGUN_CTC_API_KEY"] || EnvironmentCredentials.dig(:mailgun, :ctc_api_key))
      {
        api_key: ENV["MAILGUN_CTC_API_KEY"] || EnvironmentCredentials.dig(:mailgun, :ctc_api_key),
        domain: ENV["MAILGUN_CTC_DOMAIN"] || EnvironmentCredentials.dig(:mailgun, :ctc_domain)
      }
    elsif service_type == :statefile && (ENV["MAILGUN_STATEFILE_API_KEY"] || EnvironmentCredentials.dig(:mailgun, :statefile_api_key))
      {
        api_key: ENV["MAILGUN_STATEFILE_API_KEY"] || EnvironmentCredentials.dig(:mailgun, :statefile_api_key),
        domain: ENV["MAILGUN_STATEFILE_DOMAIN"] || EnvironmentCredentials.dig(:mailgun, :statefile_domain)
      }
    else
      Rails.configuration.action_mailer.mailgun_settings
    end
  end

  def current_tax_year(time = DateTime.now)
    case service_type
    when :ctc then Rails.configuration.ctc_current_tax_year
    when :gyr then gyr_current_tax_year(time)
    when :statefile then Rails.configuration.statefile_current_tax_year
    end
  end

  def between_deadline_and_end_of_in_progress_intake?(now = DateTime.now)
    now.between?(Rails.configuration.tax_deadline, Rails.configuration.end_of_in_progress_intake)
  end

  def filing_years(now = DateTime.now)
    if service_type == :ctc || service_type == :state_file
      [current_tax_year]
    else
      years = Rails.configuration.tax_year_filing_seasons.select do |_, (season_start, _)|
        now > season_start - 3.months
      end.keys.sort.reverse.take(3)

      years += [years.last - 1] if now < Rails.configuration.tax_year_filing_seasons[years.first].last

      years.freeze
    end
  end

  def backtax_years(time = DateTime.now)
    filing_years(time).without(current_tax_year(time))
  end

  def twilio_creds
    @_twilio_creds ||= {
      account_sid: ENV["TWILIO_#{service_type.upcase}_ACCOUNT_SID"] || EnvironmentCredentials.dig(:twilio, service_type, :account_sid),
      auth_token: ENV["TWILIO_#{service_type.upcase}_AUTH_TOKEN"] || EnvironmentCredentials.dig(:twilio, service_type, :auth_token),
      messaging_service_sid: ENV["TWILIO_#{service_type.upcase}_MESSAGING_SERVICE_SID"] || EnvironmentCredentials.dig(:twilio, service_type, :messaging_service_sid)
    }
  end

  def twilio_status_webhook_url(outgoing_message_status_id)
    case service_type
    when :ctc then twilio_update_status_url(outgoing_message_status_id, locale: nil)
    when :gyr then twilio_update_status_url(outgoing_message_status_id, locale: nil)
    end
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

  private

  def gyr_current_tax_year(time)
    Rails.configuration.tax_year_filing_seasons.select do |_year, (open_date, _close_date)|
      time > open_date - 3.months
    end.keys.max
  end
end
