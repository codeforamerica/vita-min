class EfileSubmissionStateMachine
  include Statesman::Machine
  CLIENT_INACCESSIBLE_STATUSES = %w[waiting investigating queued cancelled].freeze

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
  state :waiting
  state :fraud_hold

  state :resubmitted
  state :cancelled

  transition from: :new,               to: [:preparing, :fraud_hold]
  transition from: :preparing,         to: [:queued, :failed, :fraud_hold]
  transition from: :queued,            to: [:transmitted, :failed, :fraud_hold]
  transition from: :transmitted,       to: [:accepted, :rejected, :failed]
  transition from: :failed,            to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold]
  transition from: :rejected,          to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold]
  transition from: :investigating,     to: [:resubmitted, :cancelled, :waiting, :fraud_hold]
  transition from: :resubmitted,       to: [:preparing]
  transition from: :waiting,           to: [:resubmitted, :cancelled, :investigating, :fraud_hold]
  transition from: :fraud_hold,        to: [:preparing, :queued, :failed, :rejected, :investigating, :resubmitted, :waiting]

  guard_transition(to: :preparing) do |_submission|
    ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'].blank?
  end

  after_transition(to: :preparing) do |submission|
    fraud_indicator_service = FraudIndicatorService.new(submission.client)
    hold_indicators = fraud_indicator_service.hold_indicators
    hold_no_dependents = ActiveModel::Type::Boolean.new.cast(ENV["FRAUD_HOLD_NO_DEPENDENTS"]) && submission.tax_return.qualifying_dependents.count.zero?
    if (hold_no_dependents || hold_indicators.present?) && !submission.admin_resubmission?
      submission.transition_to!(:fraud_hold, indicators: hold_indicators)
      # TODO: flag has been decoupled from everything (SLA, new client actions, etc) except the toggle/button. this is the only place left where it auto-flags the client. should it?
      # flag client on resubmission since an admin needs to resubmit for them
      submission.client.flag! if submission.resubmission?
    else
      # Only sends if efile preparing message has never been sent bc
      # AutomatedMessage::EfilePreparing has send_only_once set to true
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: submission.client,
        message: AutomatedMessage::EfilePreparing
      )
      BuildSubmissionBundleJob.perform_later(submission.id)
      submission.tax_return.transition_to(:file_ready_to_file)
    end
  end

  after_transition(to: :queued) do |submission|
    GyrEfiler::SendSubmissionJob.perform_later(submission)
  end

  after_transition(to: :fraud_hold) do |submission|
    submission.tax_return.transition_to(:file_fraud_hold)
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: submission.client,
      message: AutomatedMessage::InformOfFraudHold,
      locale: submission.client.intake.locale,
    )
  end

  after_transition(to: :transmitted) do |submission|
    submission.tax_return.transition_to(:file_efiled)
    send_mixpanel_event(submission, "ctc_efile_return_transmitted")
  end

  after_transition(to: :failed, after_commit: true) do |submission, transition|
    submission.tax_return.transition_to(:file_needs_review)

    Efile::SubmissionErrorParser.persist_errors(transition)

    if transition.efile_errors.any?
      if transition.efile_errors.any?(&:expose)
        ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
          client: submission.client,
          message: AutomatedMessage::EfileFailed,
          locale: submission.client.intake.locale
        )
      end
      submission.transition_to!(:waiting) if transition.efile_errors.all?(&:auto_wait)
    end

    send_mixpanel_event(submission, "ctc_efile_return_failed")
  end

  after_transition(to: :rejected, after_commit: true) do |submission, transition|
    AfterTransitionTasksForRejectedReturnJob.perform_later(submission, transition)
  end

  after_transition(to: :accepted) do |submission|
    # Add a note to client page
    client = submission.client
    tax_return = submission.tax_return
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: client,
      message: AutomatedMessage::EfileAcceptance,
      locale: client.intake.locale
    )
    tax_return.transition_to(:file_accepted)
    tax_return.record_expected_payments!
    send_mixpanel_event(submission, "ctc_efile_return_accepted", data: {
      child_tax_credit_advance: tax_return.expected_advance_ctc_payments,
      recovery_rebate_credit: tax_return.claimed_recovery_rebate_credit,
      third_stimulus_amount: tax_return.expected_recovery_rebate_credit_three,
    })
  end

  after_transition(to: :investigating) do |submission|
    submission.tax_return.transition_to(:file_hold)
  end

  after_transition(to: :waiting) do |submission|
    submission.tax_return.transition_to(:file_hold)
  end

  after_transition(to: :resubmitted) do |submission|
    if submission.efile_submission_transitions.where(to_state: :transmitted).count.zero?
      submission.transition_to!(:preparing)
    else
      # Re-submission doesn't involve client interaction so we use e-file security information from the last interaction
      @new_submission = submission.tax_return.efile_submissions.create
      @new_submission.transition_to!(:preparing, previous_submission_id: submission.id)
    end
  end

  after_transition(to: :cancelled) do |submission|
    submission.tax_return.transition_to(:file_not_filing)
  end

  def self.send_mixpanel_event(efile_submission, event_name, data: {})
    MixpanelService.send_event(
      distinct_id: efile_submission.client.intake.visitor_id,
      event_name: event_name,
      subject: efile_submission.intake,
      data: data,
    )
  end
end
