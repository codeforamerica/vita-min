class SimpleFileUrlService
  SOURCES = %w[
    gyrsel
    gyrhomepage
  ].freeze

  STATE_CODES = {
    "CO" => "1",
    "NJ" => "2"
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

    uri.query = {
      state: state_code,
      source: supported_source
    }.to_query

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
    SOURCES.fetch(SOURCES.index(source)) do
      raise ArgumentError, "Unsupported Simple File source: #{source.inspect}"
    end
  end

  def state_code
    STATE_CODES.fetch(intake.state_of_residence) do
      raise ArgumentError,
            "Unsupported Simple File state: #{intake.state_of_residence.inspect}"
    end
  end
end