module StateFile
  class MonthlyFinishStateReturnService
    def self.run
      message = StateFile::AutomatedMessage::MonthlyFinishReturn
      intakes_with_no_submission = StateFile::StateInformationService.active_state_codes.excluding("ny").flat_map do |state_code|
        intake_class = StateFile::StateInformationService.intake_class(state_code)
        intake_class
          .where("df_data_imported_at < ?", 6.hours.ago)
          .where("#{intake_class.name.underscore}s.created_at >= ?", Time.current.beginning_of_year)
          .has_verified_contact_info
          .left_joins(:efile_submissions).where(efile_submissions: { id: nil })
          .select do |intake|
          next false if intake.disqualifying_df_data_reason.present? || intake.other_intake_with_same_ssn_has_submission?

          if (msg = intake.message_tracker&.dig("messages.state_file.monthly_finish_return"))
            Time.parse(msg) < 1.month.ago
          elsif (msg = intake.message_tracker&.dig("messages.state_file.finish_return"))
            Time.parse(msg) < 24.hours.ago
          else
            true
          end
        end
      end

      batch_size = 50
      intakes_with_no_submission.each_slice(batch_size) do |batch|
        batch.each do |intake|
          begin
            StateFile::MessagingService.new(message: message, intake: intake).send_message(require_verification: false)
          rescue => e
            Sentry.capture_exception(e, extra: { intake_id: intake.id })
          end
        end
      end
    end
  end
end
