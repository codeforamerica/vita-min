module StateFile
  class ReminderToFinishStateReturnService
    def self.run
      intakes_with_no_submission = StateFile::StateInformationService.active_state_codes.flat_map do |state_code|
        intake_class = StateFile::StateInformationService.intake_class(state_code)
        intake_class
          .left_joins(:efile_submissions)
          .where(df_data_imported_at: Time.current.beginning_of_year..6.hours.ago)
          .where(efile_submissions: { id: nil })
          .where.not("state_file_#{state_code}_intakes.message_tracker #> '{messages.state_file.finish_return}' IS NOT NULL")
          .where(<<~SQL)
            (
              phone_number IS NOT NULL
              AND sms_notification_opt_in = 1
              AND phone_number_verified_at IS NOT NULL
            )
            OR
            (
              email_address IS NOT NULL
              AND email_notification_opt_in = 1
              AND email_address_verified_at IS NOT NULL
            )
          SQL
      end

      batch_size = 50
      intakes_with_no_submission.each_slice(batch_size) do |batch|
        batch.each do |intake|
          begin
            StateFile::MessagingService.new(message: StateFile::AutomatedMessage::FinishReturn, intake: intake).send_message
          rescue => e
            Sentry.capture_exception(e, extra: { intake_id: intake.id })
          end
        end
      end
    end
  end
end
