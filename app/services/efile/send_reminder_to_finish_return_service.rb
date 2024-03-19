module Efile
  class ReminderToFinishStateReturn
    def self.run
      time_range = (Time.now - 24.hours)..Time.now
      msg = StateFile::AutomatedMessage::FinishReturn
      intakes_with_no_submission = StateFileAzIntake.where(df_data_imported_at: time_range)
                                                    .left_joins(:efile_submissions)
                                                    .where(efile_submissions: { id: nil })
      intakes_with_no_submission += StateFileNyIntake.where(df_data_imported_at: time_range)
                                                     .left_joins(:efile_submissions)
                                                     .where(efile_submissions: { id: nil })
      # TODO | add batching?
      intakes_with_no_submission.each do |intake|
        StateFile::MessagingService.new(message: msg, intake: intake).send_message
      end
    end
  end
end
