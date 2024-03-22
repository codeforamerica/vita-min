namespace :reminder_to_finish do
  desc 'Send reminder to finish state return notifications to all state file intakes with df_data that haven\'t submitted'
  task 'send state return notifications' => :environment do
    BATCH_SIZE = 10

    intakes = StateFileAzIntake.without_raw_data_and_no_federal_submission
    intakes += StateFileNyIntake.without_raw_data_and_no_federal_submission
  end
end
