class FraudIndicatorService
  def initialize(client)
    @client = client
    @efile_security_informations = client.efile_security_informations
  end

  HOLD_INDICATORS = ["recaptcha_score", "international_timezone", "empty_timezone", "duplicate_bank_account"].freeze

  def hold_indicators
    HOLD_INDICATORS.map do |indicator|
      indicator if send(indicator)
    end.compact
  end

  # the difference between fraud_suspected? and hold_indicators.present? is that
  # eventually fraud suspected should encompass things that are fraudy but do not prompt
  # an automatic transition to the hold state.
  def fraud_suspected?
    hold_indicators.present?
  end

  private

  def acceptable_timezone_strings
    @acceptable_timezone_strings ||= begin
      us_timezones = ActiveSupport::TimeZone.us_zones.map { |tz| [tz.name, tz.tzinfo.name].uniq }.flatten.freeze
      overrides = IceNine.deep_freeze!(YAML.load_file("lib/timezone_overrides.yml"))
      overrides + us_timezones
    end
  end

  def recaptcha_score
    average = @client.recaptcha_scores_average
    average.present? && average < 0.3
  end

  def international_timezone
    @efile_security_informations.any? { |esi| esi.timezone.present? && !acceptable_timezone_strings.include?(esi.timezone) }
  end

  def empty_timezone
    @efile_security_informations.any? { |esi| !esi.timezone.present? }
  end

  def duplicate_bank_account
    bank_account = @client.intake.bank_account
    bank_account.present? && bank_account.duplicates.exists?
  end
end