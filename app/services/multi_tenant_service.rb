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
end