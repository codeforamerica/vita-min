module StateFile
  class SendRejectResolutionReminderNotificationJob < ApplicationJob
    def perform(intake)
      return if intake.other_intake_with_same_ssn_has_submission?
      return unless notified_of_rejected_and_not_accepted?(intake)

      StateFile::MessagingService.new(
        intake: intake,
        message: StateFile::AutomatedMessage::RejectResolutionReminder,
        body_args: { return_status_link: return_status_link(intake) }
      ).send_message
    end

    def priority
      PRIORITY_LOW
    end

    def self.return_status_link(locale)
      Rails.application.routes.url_helpers.url_for(host: MultiTenantService.new(:statefile).host, controller: "state_file/questions/return_status", action: "edit", locale: locale)
    end

    private

    def return_status_link(intake)
      self.class.return_status_link(intake.locale || "en")
    end

    private

    def notified_of_rejected_and_not_accepted?(intake)
      transition_states = intake.efile_submissions.flat_map do |submission|
        submission.efile_submission_transitions.map(&:to_state)
      end.uniq

      last_state = intake.efile_submissions.last.current_state
      return false if transition_states.include?("accepted")
      return false unless %w[notified_of_rejection waiting].include?(last_state)

      transition_states.include?("notified_of_rejection")
    end
  end
end