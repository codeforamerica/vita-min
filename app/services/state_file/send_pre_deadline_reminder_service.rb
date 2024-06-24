module StateFile
  class SendPreDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []

      StateFile::StateInformationService.intake_classes.each do |class_object|
        intakes_to_notify += class_object.left_joins(:efile_submissions)
                                         .where(efile_submissions: { id: nil })
                                         .where.not(email_address: nil)
                                         .where.not(email_address_verified_at: nil)
                                         .where(unsubscribed_from_email: false)
                                         .where("#{base_class.underscore.pluralize}.message_tracker #> '{messages.state_file.pre_deadline_reminder}' IS NULL")
                                         .select do |intake|
                                            if intake.message_tracker.present? && intake.message_tracker["messages.state_file.finish_return"]
                                              finish_return_msg_sent_time = Time.parse(intake.message_tracker["messages.state_file.finish_return"])
                                              finish_return_msg_sent_time < cutoff_time_ago
                                            else
                                              true
                                            end
                                          end
                                        end

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            message: StateFile::AutomatedMessage::PreDeadlineReminder,
            intake: intake
          ).send_message
        end
      end
    end
  end
end
