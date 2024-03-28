module StateFile
  class ReminderToFinishStateReturnService
    def self.run
      cutoff_time = 23.hours + 50.minutes
      cutoff_time_ago = cutoff_time.ago
      msg = StateFile::AutomatedMessage::FinishReturn
      batch_size = 10
      intakes_with_no_submission = StateFileAzIntake.where("df_data_imported_at < ?", cutoff_time_ago)
                                                    .left_joins(:efile_submissions)
                                                    .where(efile_submissions: { id: nil })
      intakes_with_no_submission += StateFileNyIntake.where("df_data_imported_at < ?", cutoff_time_ago)
                                                     .left_joins(:efile_submissions)
                                                     .where(efile_submissions: { id: nil })

      intakes_with_no_submission.each_slice(batch_size) do |batch|
        batch.each do |intake|
          StateFile::MessagingService.new(message: msg, intake: intake).send_message
        end
      end
    end
  end
end
