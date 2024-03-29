module Hub
  class UpdateVerificationAttemptForm < Form
    include FormAttributes
    attr_accessor :verification_attempt, :current_user

    set_attributes_for :verification_attempt_note, :note
    set_attributes_for :transition, :state

    validates :note, presence: { message: "A note is required when escalating a verification attempt.", if: -> { state == "escalated"} }
    validates :note, presence: { message: "A note is required when approving a client with a bypass request.", if: -> { state == "approved" && verification_attempt.client_bypass_request.present? } }

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

    def fraud_score
      verification_attempt.client.fraud_scores.last
    end

    def fraud_indicators
      @fraud_indicators ||= Fraud::Indicator.unscoped
    end

    def can_write_note?
      verification_attempt.can_transition_to?(:approved) || verification_attempt.can_transition_to?(:denied)
    end

    def can_handle_escalations?
      current_user.admin? || current_user.client_success?
    end
  end
end