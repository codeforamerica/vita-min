class EfileSubmissionStateMachine
  include Statesman::Machine
  CLIENT_INACCESSIBLE_STATUSES = %w[waiting investigating queued cancelled].freeze

  state :new, initial: true
  state :preparing
  state :bundling
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

  transition from: :new,               to: [:preparing]
  transition from: :preparing,         to: [:bundling, :fraud_hold]
  transition from: :bundling,          to: [:queued, :failed]
  transition from: :queued,            to: [:transmitted, :failed]
  transition from: :transmitted,       to: [:accepted, :rejected, :failed]
  transition from: :failed,            to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold]
  transition from: :rejected,          to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold]
  transition from: :investigating,     to: [:resubmitted, :cancelled, :waiting, :fraud_hold]
  transition from: :waiting,           to: [:resubmitted, :cancelled, :investigating, :fraud_hold]
  transition from: :fraud_hold,        to: [:investigating, :resubmitted, :waiting, :cancelled]

  guard_transition(to: :bundling) do |_submission|
    ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'].blank?
  end

  guard_transition(to: :bundling) do |submission|
    submission.fraud_score.present?
  end

  after_transition(to: :preparing) do |submission|
    submission.create_qualifying_dependents

    fraud_score = Fraud::Score.create_from(submission)
    bypass_fraud_check = submission.admin_resubmission? || submission.client.identity_verified_at
    if bypass_fraud_check || fraud_score.score < Fraud::Score::HOLD_THRESHOLD
      submission.transition_to(:bundling)
    else
      submission.client.touch(:restricted_at) if fraud_score.score > Fraud::Score::RESTRICT_THRESHOLD
      submission.transition_to(:fraud_hold)
    end
  end

  after_transition(to: :bundling) do |submission|
    # Only sends if efile preparing message has never been sent bc
    # AutomatedMessage::EfilePreparing has send_only_once set to true
    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: submission.client,
      message: AutomatedMessage::EfilePreparing
    )
    submission.tax_return.transition_to!(:file_ready_to_file)

    BuildSubmissionBundleJob.perform_later(submission.id)
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

    benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: submission.qualifying_dependents)
    ctc_amount = benefits.ctc_amount / 2
    refund_amount = client.intake.claim_owed_stimulus_money_no? ? 0 : (benefits.eip1_amount + benefits.eip2_amount)
    eip3_amount = benefits.eip3_amount

    # TODO: Update analytics table to report relevant information for tax year
    submission.tax_return.create_accepted_tax_return_analytics!(
      advance_ctc_amount_cents: ctc_amount * 100,
      refund_amount_cents: refund_amount * 100,
      eip3_amount_cents: eip3_amount * 100
    )

    send_mixpanel_event(submission, "ctc_efile_return_accepted", data: {
      child_tax_credit_advance: ctc_amount,
      recovery_rebate_credit: refund_amount,
      third_stimulus_amount: eip3_amount,
    })
  end

  after_transition(to: :investigating) do |submission|
    submission.tax_return.transition_to(:file_hold)
  end

  after_transition(to: :waiting) do |submission|
    submission.tax_return.transition_to(:file_hold)
  end
  
  after_transition(to: :resubmitted) do |submission, transition|
    @new_submission = submission.tax_return.efile_submissions.create
    @new_submission.transition_to!(:preparing, previous_submission_id: submission.id, initiated_by_id: transition.metadata["initiated_by_id"])
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
