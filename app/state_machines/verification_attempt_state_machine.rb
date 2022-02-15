class VerificationAttemptStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :approved
  state :denied
  state :escalated
  state :requested_replacements

  # Allow free transition from any state, to any state for now
  states.each do |state|
    transition from: state, to: states
  end

  after_transition(after_commit: true, to: :approved) do |verification_attempt, transition|
    verification_attempt.client.update(identity_verified_at: transition.created_at)
    efile_submission = verification_attempt.client.efile_submissions&.last
    if efile_submission.present? && efile_submission.in_state?(:fraud_hold)
      efile_submission.transition_to(:resubmitted, { initiated_by_id: transition.metadata[:initiated_by_id] })
    end
  end
end
