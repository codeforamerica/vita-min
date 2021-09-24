class FraudIndicatorService
  def initialize(submission)
    @submission = submission
    @client = submission.client
    @efile_security_informations = submission.client.efile_security_informations
  end

  HOLD_INDICATORS = ["recaptcha_score"].freeze

  def hold_indicators
    HOLD_INDICATORS.map do |indicator|
      indicator if send(indicator)
    end.compact
  end

  private

  def recaptcha_score
    @efile_security_informations.any? { |esi| esi.recaptcha_score.present? && esi.recaptcha_score <= 0.5 }
  end
end