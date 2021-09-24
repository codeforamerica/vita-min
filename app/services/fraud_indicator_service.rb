class FraudIndicatorService
  def initialize(client)
    @client = client
    @efile_security_informations = client.efile_security_informations
  end

  HOLD_INDICATORS = ["recaptcha_score"].freeze

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
    @efile_security_informations.any? { |esi| esi.recaptcha_score.present? && esi.recaptcha_score <= 0.5 }
  end
end