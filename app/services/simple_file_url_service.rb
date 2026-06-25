class SimpleFileUrlService
  SOURCES = %w[
    gyrsel
    gyrhomepage
  ].freeze

  STATE_CODES = {
    "CO" => "co",
    "NJ" => "nj"
  }.freeze

  SUPPORTED_LOCALES = %w[en es].freeze

  attr_reader :intake, :locale, :source

  def initialize(intake:, locale:, source:)
    @intake = intake
    @locale = locale.to_s
    @source = source.to_s
  end

  def url
    uri = URI.join(
      normalized_base_url,
      "#{supported_locale}/service-selection/recommendation/simplefile"
    )

    query_params = { state_code: state_code, source: supported_source }.compact

    uri.query = query_params.to_query if query_params.any?

    uri.to_s
  end

  private

  def normalized_base_url
    base_url = Rails.configuration.simple_file_url

    raise "Simple File URL is not configured" if base_url.blank?

    "#{base_url.chomp("/")}/"
  end

  def supported_locale
    return locale if locale.in?(SUPPORTED_LOCALES)

    I18n.default_locale.to_s
  end

  def supported_source
    source if source.in?(SOURCES)
  end

  def state_code
    STATE_CODES[intake&.state_of_residence]
  end
end