class EfileSubmissionStateMachine
  include Statesman::Machine
  CLIENT_INACCESSIBLE_STATUSES = %w[waiting investigating queued cancelled].freeze

  US_STATE_MAPPING_CACHE = {}

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
    # There are no currently stopped states, allow
    next true if currently_stopped_states.blank?

    data_source_type = submission.data_source_type

    state = source_to_state(data_source_type)

    # We found a state, block transition
    next false if currently_stopped_states.include?(state)
    # Allow
    next true
  end

  guard_transition(from: :failed, to: :rejected) do |_submission|
    # we need this for testing since submissions will fail on bundle in heroku and staging
    !Rails.env.production?
  end

  after_transition(to: :preparing) do |submission|
    unless submission.admin_resubmission?
      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_successful_submission_message
    end
    submission.transition_to(:bundling)
  end

  after_transition(to: :bundling) do |submission|
    StateFile::BuildSubmissionBundleJob.perform_later(submission.id)
  end

  after_transition(to: :queued) do |submission|
    StateFile::SendSubmissionJob.perform_later(submission)
    StateFile::BuildSubmissionPdfJob.perform_later(submission.id)
  end

  after_transition(to: :transmitted) do |submission|
    # NOTE: a submission can have multiple successive :transmitted states, each with different response XML
    analytics = submission.data_source.state_file_analytics
    analytics&.update(analytics.calculated_attrs)
  end

  after_transition(to: :failed, after_commit: true) do |submission, transition|
    Efile::SubmissionErrorParser.persist_errors(transition)

    if transition.efile_errors.any? && transition.efile_errors.all?(&:auto_wait)
      submission.transition_to!(:waiting)
    end

    StateFile::SendStillProcessingNoticeJob.set(wait: 24.hours).perform_later(submission)
  end

  after_transition(to: :rejected, after_commit: true) do |submission, transition|
    StateFile::AfterTransitionTasksForRejectedReturnJob.perform_later(submission, transition)
    EfileSubmissionStateMachine.send_mixpanel_event(submission, "state_file_efile_return_rejected")
    StateFile::SendStillProcessingNoticeJob.set(wait: 24.hours).perform_later(submission)
  end

  before_transition(to: :notified_of_rejection) do |submission|
    errors = submission
      &.efile_submission_transitions
      &.where(to_state: 'rejected')
      &.last
      &.efile_errors

    if errors&.any?(&:auto_cancel)
      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_terminal_rejected_message
    else
      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_rejected_message
    end
  end

  after_transition(to: :accepted) do |submission|
    StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_accepted_message
    send_mixpanel_event(submission, "state_file_efile_return_accepted")
  end
  
  after_transition(to: :resubmitted) do |submission, transition|
    @new_submission = submission.data_source.efile_submissions.create

    begin
      @new_submission.transition_to!(:preparing, previous_submission_id: submission.id, initiated_by_id: transition.metadata["initiated_by_id"])
    rescue Statesman::GuardFailedError
      Rails.logger.error "Failed to transition EfileSubmission##{@new_submission.id} to :preparing"
    end
  end

  after_transition do |submission, transition|
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

  def self.send_mixpanel_event(efile_submission, event_name, data: {})
    intake = efile_submission.data_source
    MixpanelService.send_event(
      distinct_id: intake.visitor_id,
      event_name: event_name,
      subject: intake,
      data: data,
    )
  end

  def self.source_to_state(source)
    # Note that `state_info` here will contain a two member array of key and
    # value from the original hash. will look something like
    # ['az', {intake_class: "StateFileAzIntake"]
    US_STATE_MAPPING_CACHE[source] ||= StateFile::StateInformationService::STATES_INFO.find do |state_info|
      state_info[1][:intake_class].name == source
    end[0]
  end

  def self.currently_stopped_states
    ENV.fetch('HOLD_OFF_EFILE_SUBMISSIONS_FOR_STATES', '').downcase.split
  end
end
