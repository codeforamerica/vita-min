module StateFile
  class SendMarketingEmailService
    def self.run
      message = StateFile::AutomatedMessage::MarketingEmail
      archived_az_intakes = StateFileArchivedIntake.where(state_code: "az")

      batch_size = 50
      archived_az_intakes.each_slice(batch_size) do |batch|
        batch.each do |archived_intake|
          begin
            az_intakes_with_matching_ssn_and_import = StateFileAzIntake.where(hashed_ssn: archived_intake.hashed_ssn).where.not(df_data_imported_at: nil)
            next if az_intakes_with_matching_ssn_and_import.any?

            message_instance = message.new
            StateFileNotificationEmail.create!(
              data_source: archived_intake,
              to: archived_intake.email_address,
              body: message_instance.email_body,
              subject: message_instance.email_subject,
            )
          rescue => e
            Sentry.capture_exception(e, extra: { archived_intake_id: archived_intake.id })
          end
        end
      end
    end
  end
end
