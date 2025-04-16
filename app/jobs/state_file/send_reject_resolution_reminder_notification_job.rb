module StateFile
  class SendRejectResolutionReminderNotificationJob < ApplicationJob
    def perform(intake)
      return if other_intake_with_same_ssn_has_submission(intake)
      return unless notified_of_rejected_and_not_accepted(intake)

      StateFile::MessagingService.new(
        intake: intake,
        message: StateFile::AutomatedMessage::RejectResolutionReminder,
        body_args: { return_status_link: return_status_link(intake) }
      ).send_message(require_verification: false)
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

    def other_intake_with_same_ssn_has_submission(intake)
      return if intake.hashed_ssn.nil?
      StateInformationService.state_intake_classes.any? do |intake_class|
        intakes = intake_class
          .where(hashed_ssn: intake.hashed_ssn)
          .where.associated(:efile_submissions)
        intakes = intakes.where.not(id: intake.id) if intake_class == intake.class
        intakes.present?
      end
    end

    def notified_of_rejected_and_not_accepted(intake)
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