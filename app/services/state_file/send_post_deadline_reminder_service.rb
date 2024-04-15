module StateFile
  class SendPostDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []

      # TODO: run in development to view the sql run here
      ApplicationRecord::STATE_INTAKE_CLASS_NAMES.each do |base_class|
        class_object = base_class.constantize
        intakes_to_notify += class_object.left_joins(:efile_submissions)
                                         .where(efile_submissions: { id: nil })
                                         .where.not(email_address: nil)
                                         .where.not(email_address_verified_at: nil)
                                         .where(unsubscribed_from_email: false)
                                         .where("#{base_class.underscore.pluralize}.message_tracker #> '{messages.state_file.post_deadline_reminder}' IS NULL")
                                         .select do |intake|

          # The finish_return message is a different reminder to finish your return. If it was sent recently, don't send this one.
          if intake.message_tracker.present? && intake.message_tracker["messages.state_file.finish_return"]
            finish_return_msg_sent_time = Date.parse(intake.message_tracker["messages.state_file.finish_return"])
            finish_return_msg_sent_time < cutoff_time_ago
          else
            true
          end
        end
      end

      # Check if any submitted intakes have a matching email with intakes_to_notify
      accepted_intakes = EfileSubmission.joins(:efile_submission_transitions)
                                        .for_state_filing
                                        .where("efile_submission_transitions.to_state = 'accepted'")
                                        .extract_associated(:data_source)

      accepted_intakes = accepted_intakes.reject { |intake| intake.email_address.nil? }


      intakes_without_matching_accepted_intake = intakes_to_notify.reject do |intake|
        accepted_intakes.any? { |accepted_intake|
          intake.email_address.casecmp(accepted_intake.email_address).zero?
        }
      end

      intakes_without_matching_accepted_intake.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            message: StateFile::AutomatedMessage::PostDeadlineReminder,
            intake: intake
          ).send_message
        end
      end
    end
  end
end
