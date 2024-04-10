module StateFile
  class SendPreDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []
      #  Is there a better way of doing this filtering? DB query seems tricky
      ApplicationRecord::STATE_INTAKE_CLASS_NAMES.map do |base_class|
        class_object = base_class.constantize
        intakes_to_notify += class_object.left_joins(:efile_submissions)
                                         .where(efile_submissions: { id: nil })
                                         .where("#{base_class.underscore.pluralize}.created_at < ?", cutoff_time_ago)
                                         .where.not(email_address: nil).where.not(email_address_verified_at: nil)
                                         .where(unsubscribed_from_email: false)
                                         .where.not("#{base_class.underscore.pluralize}.message_tracker #> '{messages.state_file.pre_deadline_reminder}' IS NOT NULL")
      end

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          msg_tracker_last_reminder = intake.message_tracker["messages.state_file.finish_return"]
          unless msg_tracker_last_reminder
            send_notification(intake)
            next
          end
          if ActiveSupport::TimeZone['UTC'].parse(msg_tracker_last_reminder) > cutoff_time_ago
            # We've sent the reminder notification less than the cutoff time ago, so don't re-send
            next
          else
            send_notification(intake)
          end
        end
      end
    end

    private

    def send_notification(intake)
      StateFile::MessagingService.new(
        message: StateFile::AutomatedMessage::PreDeadlineReminder,
        intake: intake
      ).send_message
    end
  end
end
