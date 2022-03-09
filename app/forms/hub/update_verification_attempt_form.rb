module Hub
  class UpdateVerificationAttemptForm < Form
    include FormAttributes
    attr_accessor :verification_attempt, :current_user

    set_attributes_for :verification_attempt_note, :note
    set_attributes_for :transition, :state

    validates :note, presence: { message: "A note is required when escalating a verification attempt.", if: -> { state == "escalated"} }
    validates :state, presence: true

    def initialize(verification_attempt, current_user, params)
      @verification_attempt = verification_attempt
      @current_user = current_user
      super(params)
    end

    def save
      metadata = {
        initiated_by_id: current_user.id,
        note: note
      }
      verification_attempt.transition_to!(state, metadata)
    end

    # ensure that fraud_indicators are available if show re-renders after failed update
    def fraud_indicators
      FraudIndicatorService.new(verification_attempt.client).hold_indicators
    end

    def can_write_note?
      verification_attempt.can_transition_to?(:approved) || verification_attempt.can_transition_to?(:denied)
    end

    def can_handle_escalations?
      current_user.admin? || current_user.customer_support?
    end
  end
end