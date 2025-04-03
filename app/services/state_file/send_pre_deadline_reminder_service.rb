module StateFile
  class SendPreDeadlineReminderService
    BATCH_SIZE = 1_000
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []

      StateFile::StateInformationService.state_intake_classes.excluding(StateFileNyIntake).each do |class_object|
        intakes_to_notify += class_object.left_joins(:efile_submissions)
                                         .where(efile_submissions: { id: nil })
                                         .where.not(df_data_imported_at: nil)
                                         .messaging_eligible
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
