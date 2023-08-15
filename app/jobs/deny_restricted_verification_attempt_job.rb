class DenyRestrictedVerificationAttemptJob < ApplicationJob
  def perform(verification_attempt)
    return unless verification_attempt.current_state == "restricted"

    verification_attempt.transition_to(:denied)
  end

  def priority
    PRIORITY_LOW
  end
end