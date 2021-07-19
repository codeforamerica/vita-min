class EfileSubmissionStateMachine
  include Statesman::Machine

  state :new, initial: true
  state :preparing
  state :queued

  # submission-related response statuses
  state :transmitted
  state :failed

  # terminal response statuses from IRS
  state :rejected
  state :accepted

  # I know we'll need some "internal" statuses to track filings that need internal attention, but I don't
  # know what they are yet so let's not think too far ahead.

  transition from: :new,          to: [:preparing]
  transition from: :preparing,    to: [:queued, :failed]
  transition from: :queued,       to: [:transmitted, :failed, :rejected]
  transition from: :transmitted,  to: [:accepted, :rejected]

  guard_transition(to: :queued) do |submission|
    submission.submission_bundle.present?
  end

  after_transition(to: :preparing) do |submission|
    BuildSubmissionBundleJob.perform_later(submission.id)
  end

  after_transition(to: :queued) do |submission|
    GyrEfiler::SendSubmissionJob.perform_later(submission)
  end

  after_transition(to: :rejected) do |submission, transition|
    # Transition associated tax return to rejected
    # Add note with rejection reason to client notes
    # Transition to flagged if needs manual changes by a person
    # Use transition metadata error code and reason to determine whether it is an eng or VITA problem.
  end

  after_transition(to: :accepted) do |submission|
    # Send a message to client
    # Add a note to client page
    # Transition associated tax return to Accepted
  end
end
