module Hub
  class UpdateVerificationAttemptForm < Form
    include FormAttributes
    attr_accessor :verification_attempt, :current_user

    set_attributes_for :verification_attempt_note, :body

    validates :body, presence: true
    def initialize(verification_attempt, current_user, params)
      @verification_attempt = verification_attempt
      @current_user = current_user
      super(params)
    end

    def save
      if body.present?
        verification_attempt.notes.create(body: body, user: current_user)
      end
    end

    # ensure that fraud_indicators are available if show re-renders after failed update
    def fraud_indicators
      FraudIndicatorService.new(verification_attempt.client).hold_indicators
    end
  end
end