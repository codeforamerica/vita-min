module StateFile
  class SendDeadlineReminderTodayService
    BATCH_SIZE = 100

    def self.run
      intakes_to_notify = []
      StateFile::StateInformationService.state_intake_classes.excluding(StateFileNyIntake).each do |class_object|
        intakes_to_notify += class_object.selected_intakes_for_deadline_reminder_soon_notifications
      end

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          begin
            StateFile::MessagingService.new(
              message: StateFile::AutomatedMessage::DeadlineReminderToday,
              intake: intake
            ).send_message
          rescue Exception => e
            Sentry.capture_exception(e, extra: {
              intake_id: intake.id,
              intake_class: intake.class.table_name
            })
          end
        end
      end
    end
  end
end
