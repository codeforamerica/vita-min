module StateFile
  class ReminderToFinishStateReturnService
    BATCH_SIZE = 10
    HOURS_AGO = 12
    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = []

      ApplicationRecord::STATE_INTAKE_CLASS_NAMES.each do |base_class|
        class_object = base_class.constantize
        intakes_to_notify += class_object.where("#{base_class.underscore.pluralize}.created_at < ?", cutoff_time_ago)
                                         .where.not(email_address: nil).where.not(email_address_verified_at: nil)
                                         .where(unsubscribed_from_email: false)
                                         .where("#{base_class.underscore.pluralize}.message_tracker #> '{messages.state_file.finish_return}' IS NULL")
      end

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            message: StateFile::AutomatedMessage::FinishReturn, intake: intake
          ).send_message
        end
      end
    end
  end
end
