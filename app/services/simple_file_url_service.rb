class SimpleFileUrlService
  SOURCES = %w[gyrsel gyrhomepage].freeze
  SUPPORTED_STATES = %w[CO NJ].freeze
  SUPPORTED_LOCALES = %w[en es].freeze

  attr_reader :intake, :locale, :source

  def initialize(intake:, locale:, source: "")
    @intake = intake
    @locale = locale.to_s
    @source = source.to_s
  end

  def url
    build_url("service-selection/recommendation/simplefile", state_code: state_code, source: filtered_source)
  end

  def welcome_url
    build_url("welcome", source: filtered_source)
  end

  private

  def build_url(path, params = {})
    uri = localized_uri(path)
    query_params = params.compact
    uri.query = query_params.to_query if query_params.any?
    uri.to_s
  end

  def localized_uri(path)
    URI.join(normalized_base_url, "#{supported_locale}/#{path}")
  end

  def normalized_base_url
    base_url = Rails.configuration.simple_file_url
    raise "Simple File URL is not configured" if base_url.blank?

    "#{base_url.chomp('/')}/"
  end

  def supported_locale
    return locale if locale.in?(SUPPORTED_LOCALES)

    I18n.default_locale.to_s
  end

  def filtered_source
    source if source.in?(SOURCES)
  end

  def state_code
    state = intake&.state_of_residence
    state.downcase if state.in?(SUPPORTED_STATES)
  end
end