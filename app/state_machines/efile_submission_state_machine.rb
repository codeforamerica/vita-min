class EfileSubmissionStateMachine
  include Statesman::Machine

  state :new, initial: true
  state :preparing
  state :queued
  state :transmitted
  state :failed
  state :rejected
  state :accepted
  state :flagged
  state :cancelled

  transition from: :new,          to: [:preparing]
  transition from: :preparing,    to: [:cancelled, :flagged]
  transition from: :queued,       to: [:transmitted, :failed, :rejected]
  transition from: :transmitted,  to: [:accepted, :rejected, :cancelled]
  transition from: :rejected,     to: [:cancelled, :flagged, :preparing]

  guard_transition(to: :queued) do |submission|
    # submission.submission_file.present?
  end

  after_transition(to: :preparing, after_commit: true) do |submission|
    # submission.build_submission_file
  end

  after_transition(to: :queued) do |submission|
    # SubmitReturnJob.perform_later(submission)
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