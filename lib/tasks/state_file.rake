namespace :state_file do
  desc 'Tasks for state-file'

  task reminder_to_finish_state_return: :environment do
    StateFile::ReminderToFinishStateReturnService.run
  end
end
