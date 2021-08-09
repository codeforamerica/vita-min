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

  state :investigating
  state :resubmitted
  state :cancelled

  transition from: :new,          to: [:preparing]
  transition from: :preparing,    to: [:queued, :failed]
  transition from: :queued,       to: [:transmitted, :failed]
  transition from: :transmitted,  to: [:accepted, :rejected]
  transition from: :failed,       to: [:resubmitted, :cancelled, :investigating]
  transition from: :rejected,     to: [:resubmitted, :cancelled, :investigating]
  transition from: :investigating, to: [:resubmitted, :cancelled]
  transition from: :resubmitted, to: [:preparing]

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

    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: submission.client,
      message: AutomatedMessage::EfileRejected.new,
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

  after_transition(to: :investigating) do |submission|
    submission.tax_return.update(status: :file_hold)
  end

  after_transition(to: :resubmitted) do |submission|
    if submission.efile_submission_transitions.where(to_state: :transmitted).count.zero?
      submission.transition_to!(:preparing)
    else
      # Re-submission doesn't involve client interaction so we use e-file security information from the last interaction
      @new_submission = submission.tax_return.efile_submissions.create!(
        efile_security_information_attributes:
          submission.efile_security_information.attributes.except("efile_submission_id", "id", "created_at", "updated_at")
      )
      @new_submission.transition_to!(:preparing, previous_submission_id: submission.id)
    end
  end

  after_transition(to: :cancelled) do |submission|
    submission.tax_return.update(status: "file_not_filing")
  end
end
