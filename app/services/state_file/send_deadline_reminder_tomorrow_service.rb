module StateFile
  class SendDeadlineReminderTomorrowService
    BATCH_SIZE = 100

    def self.run
      intakes_to_notify = []

      StateFile::StateInformationService.state_intake_classes
        .excluding(StateFileNyIntake).each do |class_object|
          intakes_to_notify += class_object.selected_intakes_for_deadline_reminder_tomorrow_notifications
      end

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            message: StateFile::AutomatedMessage::DeadlineReminderTomorrow,
            intake: intake
          ).send_message
        end
      end
    end
  end
end