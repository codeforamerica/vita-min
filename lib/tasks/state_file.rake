namespace :state_file do
  desc 'Tasks for state-file'

  task reminder_to_finish_state_return: :environment do
    StateFile::ReminderToFinishStateReturnService.run
  end
  
  task pre_deadline_reminder: :environment do
    return unless DateTime.now.year == 2024
    StateFile::SendPreDeadlineReminderService.run
  end

  task post_deadline_reminder: :environment do
    return unless DateTime.now.year == 2024
    StateFile::SendPostDeadlineReminderService.run
  end

  task send_reminder_apology_message: :environment do
    return unless DateTime.now.year == 2024
    StateFile::SendReminderApologyService.run
  end
end
