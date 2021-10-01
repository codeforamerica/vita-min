class FraudIndicatorService
  def initialize(client)
    @client = client
    @efile_security_informations = client.efile_security_informations
  end

  US_TIMEZONE_STRINGS = ActiveSupport::TimeZone.us_zones.map { |tz| [tz.name, tz.tzinfo.name].uniq }.flatten.freeze

  HOLD_INDICATORS = ["recaptcha_score", "international_timezone", "empty_timezone"].freeze

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

  def recaptcha_score
    @efile_security_informations.any? { |esi| esi.recaptcha_score.present? && esi.recaptcha_score < 0.3 }
  end

  def international_timezone
    @efile_security_informations.any? { |esi| esi.timezone.present? && !US_TIMEZONE_STRINGS.include?(esi.timezone) }
  end

  def empty_timezone
    @efile_security_informations.any? { |esi| !esi.timezone.present? }
  end
end