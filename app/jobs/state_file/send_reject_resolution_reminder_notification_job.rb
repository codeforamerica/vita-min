module StateFile
  class SendRejectResolutionReminderNotificationJob < ApplicationJob
    def perform(intake)
      return unless notified_of_rejected_and_not_accepted(intake)

      StateFile::MessagingService.new(
        intake: intake,
        message: StateFile::AutomatedMessage::RejectResolutionReminder,
        body_args: { return_status_link: return_status_link(intake) }
      ).send_message
    end

    def priority
      PRIORITY_LOW
    end

    private

    def return_status_link(intake)
      locale = intake.locale || "en"
      Rails.application.routes.url_helpers.url_for(host: MultiTenantService.new(:statefile).host, controller: "state_file/questions/return_status", action: "edit", locale: locale)
    end

    def notified_of_rejected_and_not_accepted(intake)
      transition_states = intake.efile_submissions.flat_map do |submission|
        submission.efile_submission_transitions.map(&:to_state)
      end.uniq

      last_state = intake.efile_submissions.last.current_state
      in_progress_states = ["preparing", "bundling", "queued", "transmitted", "ready_for_ack"]
      return false if transition_states.include?("accepted") || in_progress_states.include?(last_state)

      transition_states.include?("notified_of_rejection")
    end
  end
end