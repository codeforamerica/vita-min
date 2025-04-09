module StateFile
  class SendPreDeadlineReminderService
    BATCH_SIZE = 100
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []

      StateFile::StateInformationService.state_intake_classes.excluding(StateFileNyIntake).each do |class_object|
        intakes_to_notify += class_object.left_joins(:efile_submissions)
                                         .where(efile_submissions: { id: nil })
                                         .where.not(df_data_imported_at: nil)
                                         .has_verified_contact_info
                                         .select do |intake|
                                            if intake.message_tracker.present? && intake.message_tracker["messages.state_file.finish_return"]
                                              finish_return_msg_sent_time = Time.parse(intake.message_tracker["messages.state_file.finish_return"])
                                              finish_return_msg_sent_time < cutoff_time_ago
                                            elsif intake.disqualifying_df_data_reason.present?
                                              false
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
          ).send_message(require_verification: false)
        end
      end
    end
  end
end
