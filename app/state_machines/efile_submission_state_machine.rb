class EfileSubmissionStateMachine
  include Statesman::Machine
  CLIENT_INACCESSIBLE_STATUSES = %w[waiting investigating queued cancelled].freeze

  state :new, initial: true
  state :preparing
  state :bundling
  state :queued

  # submission-related response statuses
  state :transmitted
  state :ready_for_ack
  state :failed

  # terminal response statuses from IRS
  state :rejected
  state :accepted

  state :notified_of_rejection
  state :investigating
  state :waiting
  state :fraud_hold

  state :resubmitted
  state :cancelled

  transition from: :new,                   to: [:preparing]
  transition from: :preparing,             to: [:bundling, :fraud_hold]
  transition from: :bundling,              to: [:queued, :failed]
  transition from: :queued,                to: [:transmitted, :failed]
  transition from: :transmitted,           to: [:accepted, :rejected, :failed, :ready_for_ack, :transmitted, :notified_of_rejection]
  transition from: :ready_for_ack,         to: [:accepted, :rejected, :failed, :ready_for_ack, :notified_of_rejection]
  transition from: :failed,                to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold, :rejected]
  transition from: :rejected,              to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold, :notified_of_rejection]
  transition from: :notified_of_rejection, to: [:resubmitted, :cancelled, :investigating, :waiting, :fraud_hold]
  transition from: :investigating,         to: [:resubmitted, :cancelled, :waiting, :fraud_hold]
  transition from: :waiting,               to: [:resubmitted, :cancelled, :investigating, :fraud_hold, :notified_of_rejection]
  transition from: :fraud_hold,            to: [:investigating, :resubmitted, :waiting, :cancelled]
  transition from: :cancelled,             to: [:investigating, :waiting]

  guard_transition(to: :bundling) do |_submission|
    ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'].blank?
  end

  guard_transition(to: :bundling) do |submission|
    submission.is_for_state_filing? || submission.fraud_score.present?
  end

  guard_transition(from: :failed, to: :rejected) do |_submission|
    # we need this for testing since submissions will fail on bundle in heroku and staging
    !Rails.env.production?
  end

  after_transition(to: :preparing) do |submission|
    StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_successful_submission_message if submission.is_for_state_filing?

    submission.create_qualifying_dependents
    if submission.is_for_federal_filing?
      if submission.first_submission? && submission.intake.filing_jointly?
        submission.intake.update(spouse_prior_year_agi_amount: submission.intake.spouse_prior_year_agi_amount_computed)
      end
    end

    fraud_score = submission.is_for_federal_filing? ? Fraud::Score.create_from(submission) : Fraud::Score.new(score: 0)
    bypass_fraud_check = submission.is_for_state_filing? || submission.admin_resubmission? || submission.client.identity_verified_at
    if bypass_fraud_check || fraud_score.score < Fraud::Score::HOLD_THRESHOLD
      submission.transition_to(:bundling)
    else
      submission.client.touch(:restricted_at) if fraud_score.score >= Fraud::Score::RESTRICT_THRESHOLD
      submission.transition_to(:fraud_hold)
    end

    if submission.is_for_federal_filing?
      StateFile::CreateSubmissionPdfJob.perform_later(submission.id)
    end
  end

  after_transition(to: :bundling) do |submission|
    # Only sends if efile preparing message has never been sent bc
    # AutomatedMessage::EfilePreparing has send_only_once set to true
    if submission.is_for_federal_filing?
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: submission.client,
        message: AutomatedMessage::EfilePreparing,
      )
      submission.tax_return.transition_to!(:file_ready_to_file)
    end

    StateFile::BuildSubmissionBundleJob.perform_later(submission.id)
  end

  after_transition(to: :queued) do |submission|
    StateFile::SendSubmissionJob.perform_later(submission)
  end

  after_transition(to: :fraud_hold) do |submission|
    if submission.is_for_federal_filing?
      submission.tax_return.transition_to(:file_fraud_hold)
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: submission.client,
        message: AutomatedMessage::InformOfFraudHold,
      )
    end
  end

  after_transition(to: :transmitted) do |submission|
    if submission.is_for_federal_filing?
      submission.tax_return.transition_to(:file_efiled)
      send_mixpanel_event(submission, "efile_return_transmitted")
    end

    if submission.is_for_state_filing?
      # NOTE: a submission can have multiple successive :transmitted states, each with different
      # response XML
      analytics = submission.data_source.state_file_analytics
      analytics&.update(analytics.calculated_attrs)
    end
  end

  after_transition(to: :failed, after_commit: true) do |submission, transition|
    if submission.is_for_federal_filing?
      submission.tax_return.transition_to(:file_needs_review)
    end

    Efile::SubmissionErrorParser.persist_errors(transition)

    if transition.efile_errors.any?
      if transition.efile_errors.any?(&:expose) && submission.is_for_federal_filing?
        ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
          client: submission.client,
          message: AutomatedMessage::EfileFailed,
        )
      end
      submission.transition_to!(:waiting) if transition.efile_errors.all?(&:auto_wait)
    end

    if submission.is_for_federal_filing?
      send_mixpanel_event(submission, "ctc_efile_return_failed")
    end

    if submission.is_for_state_filing?
      StateFile::SendStillProcessingNoticeJob.set(wait: 24.hours).perform_later(submission)
    end
  end

  after_transition(to: :rejected, after_commit: true) do |submission, transition|
    StateFile::AfterTransitionTasksForRejectedReturnJob.perform_later(submission, transition)
    if submission.is_for_state_filing?
      EfileSubmissionStateMachine.send_mixpanel_event(submission, "state_file_efile_return_rejected")
      StateFile::SendStillProcessingNoticeJob.set(wait: 24.hours).perform_later(submission)
    end
  end

  before_transition(to: :notified_of_rejection) do |submission|
    if submission.is_for_state_filing?
      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_rejected_message
    end
  end

  after_transition(to: :accepted) do |submission|
    if submission.is_for_federal_filing?
      # Add a note to client page
      client = submission.client
      tax_return = submission.tax_return
      ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
        client: client,
        message: AutomatedMessage::EfileAcceptance,
      )
      tax_return.transition_to(:file_accepted)

      accepted_tr_analytics = submission.tax_return.create_accepted_tax_return_analytics!
      accepted_tr_analytics.update!(accepted_tr_analytics.calculated_benefits_attrs)

      benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: submission.qualifying_dependents)
      send_mixpanel_event(submission, "ctc_efile_return_accepted", data: {
        child_tax_credit_advance: benefits.advance_ctc_amount_received,
        recovery_rebate_credit: [benefits.eip1_amount, benefits.eip2_amount].compact.sum,
        third_stimulus_amount: benefits.eip3_amount,
      })
    elsif submission.is_for_state_filing?
      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_accepted_message
      send_mixpanel_event(submission, "state_file_efile_return_accepted")
    end
  end

  after_transition(to: :investigating) do |submission|
    # transitioning tax-return state
    submission.tax_return.transition_to(:file_hold) if submission.is_for_federal_filing?
  end


  after_transition(to: :waiting) do |submission|
    submission.tax_return.transition_to(:file_hold) if submission.is_for_federal_filing?
  end
  
  after_transition(to: :resubmitted) do |submission, transition|
    @new_submission = submission.source_record.efile_submissions.create

    begin
      @new_submission.transition_to!(:preparing, previous_submission_id: submission.id, initiated_by_id: transition.metadata["initiated_by_id"])
    rescue Statesman::GuardFailedError
      Rails.logger.error "Failed to transition EfileSubmission##{@new_submission.id} to :preparing"
    end
  end

  after_transition(to: :cancelled) do |submission|
    submission.tax_return.transition_to(:file_not_filing) if submission.is_for_federal_filing?
  end

  after_transition do |submission, transition|
    if submission.is_for_state_filing?
      from_status = (
        EfileSubmissionTransition
          .where(efile_submission_id: transition.efile_submission_id)
          .where.not(id: transition.id)
          .last
          &.to_state
      )
      Rails.logger.info({
        event_type: "submission_transition",
        from_status: from_status,
        to_status: transition.to_state,
        state_code: submission.data_source.state_code,
        intake_id: submission.data_source_id,
        submission_id: submission.id
      }.as_json)
    end
  end

  def self.send_mixpanel_event(efile_submission, event_name, data: {})
    intake = efile_submission.is_for_state_filing? ? efile_submission.data_source : efile_submission.client.intake
    MixpanelService.send_event(
      distinct_id: intake.visitor_id,
      event_name: event_name,
      subject: intake,
      data: data,
    )
  end
end
