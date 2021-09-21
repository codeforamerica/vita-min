class FraudIndicatorService
  def initialize(submission)
    @submission = submission
    @client = submission.client
    @efile_security_informations = submission.client.efile_security_informations
  end

  HOLD_INDICATORS = ["recaptcha_score"].freeze

  def assess!
    hold_indicators = []
    HOLD_INDICATORS.each do |indicator|
      hold_indicators << indicator if send(indicator)
    end
    if hold_indicators.present? && !admin_resubmission?
      @submission.transition_to!(:fraud_hold, indicators: hold_indicators)
    end
  end

  def admin_resubmission?
    reference_submission = @client.efile_submissions.length == 1 ? @submission : @submission.previously_transmitted_submission
    if reference_submission.present?
      resubmission_transition = reference_submission.last_transition_to(:resubmitted)
      resubmission_transition && resubmission_transition.initiated_by.present?
    end
  end

  private

  def recaptcha_score
    @efile_security_informations.any? { |esi| esi.recaptcha_score.present? && esi.recaptcha_score <= 0.5 }
  end
end