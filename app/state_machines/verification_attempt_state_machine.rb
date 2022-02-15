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
end
