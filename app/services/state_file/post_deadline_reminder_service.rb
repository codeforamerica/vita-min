module StateFile
  class PostDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago

      intakes_to_notify = StateFileBaseIntake::STATE_CODES.map do |code|
        no_or_old_reminder = <<~SQL
          state_file_#{code}_intakes.message_tracker #> '{messages.state_file.finish_return}' IS NULL 
          OR state_file_#{code}_intakes.message_tracker #> '{messages.state_file.finish_return}' < ?
        SQL
        "StateFile#{code.titleize}Intake".constantize
          .left_joins(:efile_submissions)
          .where(efile_submissions: { id: nil })
          .where(no_or_old_reminder, cutoff_time_ago)
      end.flatten

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            #message: StateFile::AutomatedMessage::FinishReturn,
            message: StateFile::AutomatedMessage::FinishReturn,
            intake: intake
          ).send_message
        end
      end
    end
  end
end
