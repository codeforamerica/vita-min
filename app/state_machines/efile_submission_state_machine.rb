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

  transition from: :new, to: [:preparing]
  transition from: :preparing, to: [:queued, :failed]
  transition from: :queued, to: [:transmitted, :failed, :rejected]
  transition from: :transmitted, to: [:accepted, :rejected]

  guard_transition(to: :queued) do |submission, transition|
    transition.metadata[:seeding].present? || submission.submission_bundle.present?
  end

  after_transition(to: :preparing) do |submission|
    BuildSubmissionBundleJob.perform_later(submission.id)
    submission.tax_return.update(status: "file_ready_to_file")
  end

  after_transition(to: :queued) do |submission|
    GyrEfiler::SendSubmissionJob.perform_later(submission)
  end

  after_transition(to: :transmitted) do |submission|
    submission.tax_return.update(status: "file_efiled")
  end

  after_transition(to: :failed) do |submission|
    submission.client.flag!
    submission.tax_return.update(status: "file_needs_review")
  end

  after_transition(to: :rejected) do |submission|
    # Add note with rejection reason to client notes
    # Use transition metadata error code and reason to determine whether it is an eng or VITA problem.
    submission.client.flag!
    submission.tax_return.update(status: "file_rejected")
  end

  after_transition(to: :accepted) do |submission|
    # Add a note to client page
    client = submission.client
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: client,
      message: AutomatedMessage::EfileAcceptance.new,
      locale: client.intake.locale
    )
    submission.tax_return.update(status: "file_accepted")
  end

  after_transition(from: :new, to: :preparing) do |submission|
    client = submission.client
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: client,
      message: AutomatedMessage::EfilePreparing.new,
      locale: client.intake.locale
    )
  end
end
