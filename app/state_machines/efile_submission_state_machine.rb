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

  state :resubmitted
  state :cancelled

  transition from: :new,          to: [:preparing]
  transition from: :preparing,    to: [:queued, :failed]
  transition from: :queued,       to: [:transmitted, :failed]
  transition from: :transmitted,  to: [:accepted, :rejected]
  transition from: :failed,       to: [:resubmitted, :cancelled]
  transition from: :rejected,     to: [:resubmitted, :cancelled]
  transition from: :resubmitted,  to: [:preparing]

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
    submission.tax_return.update(status: "file_needs_review")
  end

  after_transition(to: :rejected) do |submission, transition|
    submission.tax_return.update(status: "file_rejected")

    first_error = transition.efile_errors.first
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: submission.client,
      message: AutomatedMessage::EfileRejected.new(error_code: first_error&.code, error_message: first_error&.message),
      locale: submission.client.intake.locale
    )
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

  after_transition(to: :resubmitted) do |submission|
    if submission.efile_submission_transitions.where(to_state: :transmitted).count.zero?
      submission.transition_to!(:preparing)
    else
      @new_submission = submission.tax_return.efile_submissions.create!
      @new_submission.transition_to!(:preparing, previous_submission_id: submission.id)
    end
  end

  after_transition(to: :cancelled) do |submission|
    submission.tax_return.update(status: "file_not_filing")
  end
end
