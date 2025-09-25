module StateFile
  class OctoberTransferReminderService
    def self.run
      message = StateFile::AutomatedMessage::OctoberTransferReminder

      intakes_with_no_submission = StateFile::StateInformationService.active_state_codes.flat_map do |state_code|
        intake_class = StateFile::StateInformationService.intake_class(state_code)

        intake_class
          .where(df_data_import_succeeded_at: nil)
          .where("#{intake_class.table_name}.created_at >= ?", Time.current.beginning_of_year)
          .select do |intake|

          next false if intake.other_intake_with_same_ssn_has_submission?

          mt = intake.message_tracker || {}

          timestamps =
            if mt.is_a?(Hash)
              nested = mt.dig("messages", "state_file")
              nested_vals = nested.is_a?(Hash) ? nested.values : []
              flat_vals = mt.select { |k, _| k.to_s.start_with?("messages.state_file.") }.values
              nested_vals + flat_vals
            else
              []
            end

          last_sent_at = timestamps.map { |ts| Time.zone.parse(ts) rescue nil }.compact.max

          last_sent_at.nil? || last_sent_at < 24.hours.ago
        end
      end

      batch_size = 50
      intakes_with_no_submission.each_slice(batch_size) do |batch|
        batch.each do |intake|
          begin
            StateFile::MessagingService
              .new(message: message, intake: intake)
              .send_message(require_verification: false)
          end
        end
      end
    end
  end
end
