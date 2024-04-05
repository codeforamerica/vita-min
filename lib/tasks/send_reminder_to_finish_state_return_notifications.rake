namespace :reminder_to_finish do
  desc "Send reminder to finish state return notifications to all state file intakes with df_data that haven't submitted"
  task 'state_return_notifications' => :environment do
    BATCH_SIZE = 10

    msg = StateFile::AutomatedMessage::FinishReturn
    intakes = StateFileAzIntake.created_intake_but_no_federal_submission
    intakes += StateFileNyIntake.created_intake_but_no_federal_submission

    intakes.each_slice(BATCH_SIZE) do |batch|
      batch.each do |intake|
        StateFile::MessagingService.new(message: msg, intake: intake).send_message
      end
    end
  end
end
