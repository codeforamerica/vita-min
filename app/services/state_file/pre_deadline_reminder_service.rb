module StateFile
  class PreDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def self.run
      # cutoff_time_ago = HOURS_AGO.hours.ago

      intakes_to_notify = StateFileBaseIntake::STATE_CODES.map do |code|
        # TODO
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
