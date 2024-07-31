module StateFile
  class AfterTransitionTasksForRejectedReturnJob < ApplicationJob
    def perform(submission, transition)
      transition ||= submission.last_transition

      Efile::SubmissionErrorParser.persist_errors(transition)

      if transition.efile_errors.any?
        submission.transition_to!(:cancelled) if transition.efile_errors.any?(&:auto_cancel)
        submission.transition_to!(:waiting) if transition.efile_errors.all?(&:auto_wait)
        if transition.efile_errors.all? { |efile_error| EfileError.error_codes_to_retry_once.include?(efile_error.code) }
          already_auto_resubmitted = submission.previously_transmitted_submission && submission.previously_transmitted_submission.efile_submission_transitions.where(to_state: :resubmitted
          ).any? { |transition| transition.metadata.dig("auto_resubmitted") }
          unless already_auto_resubmitted
            submission.transition_to!(:resubmitted, { auto_resubmitted: true })
          end
        end
      end
    end

    def priority
      PRIORITY_LOW
    end

    private

    def message_class_for_state(state)
      return if state == 'resubmitted'
      return StateFile::AutomatedMessage::EfileRejectedAndCancelled if state == 'cancelled'

      StateFile::AutomatedMessage::EfileRejected
    end
  end
end
