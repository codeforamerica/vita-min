module StateFile
  class SendPostDeadlineReminderService
    BATCH_SIZE = 10
    HOURS_AGO = 24

    def self.run
      cutoff_time_ago = HOURS_AGO.hours.ago
      intakes_to_notify = StateFile::StateInformationService.intake_classes.map do |class_object|

        # First we get all intake ids by email address
        intake_ids_by_email = class_object.select(:id, :email_address).where.not(email_address: nil).each_with_object({}) do |intake, result|
          ids = result[intake.email_address]
          ids = [] unless ids.present?
          ids.append(intake.id)
        end

        # Next we get all intake ids by hashed SSN
        intake_ids_by_hashed_ssn = class_object.select(:id, :hashed_ssn).where.not(hashed_ssn: nil).each_with_object({}) do |intake, result|
          ids = result[intake.hashed_ssn]
          ids = [] unless ids.present?
          ids.append(intake.id)
        end

        class_object.left_joins(:efile_submissions)
                    .where(efile_submissions: { id: nil })
                    .where.not(email_address: nil)
                    .where.not(email_address_verified_at: nil)
                    .where(unsubscribed_from_email: false)
                    .where("#{class_object.name.underscore.pluralize}.message_tracker #> '{messages.state_file.post_deadline_reminder}' IS NULL")
                    .select do |intake|
          if intake.message_tracker.present? && intake.message_tracker["messages.state_file.finish_return"]
            finish_return_msg_sent_time = Time.parse(intake.message_tracker["messages.state_file.finish_return"])
            finish_return_msg_sent_time < cutoff_time_ago
          else
            true
          end
        end.select do |intake|
          # New criteria - gonna see if any associated intakes have submissions
          intake_ids = (intake_ids_by_email[intake.email_address] || []) + (intake_ids_by_hashed_ssn[intake.hashed_ssn] || [])
          intake_ids = intake_ids.to_set
          (intake_ids.length == 1) || EfileSubmission.where(data_source_id: intake_ids, data_source_type: class_object.name).none?
        end
      end.flatten

      intakes_to_notify.each_slice(BATCH_SIZE) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(
            message: StateFile::AutomatedMessage::PostDeadlineReminder,
            intake: intake
          ).send_message(require_verification: false)
        end
      end
    end
  end
end
