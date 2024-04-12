namespace :send_reject_resolution_reminder_notifications do
  desc 'Send reject resolution reminder notifications'
  task 'send' => :environment do
    intakes_to_send_message_to.each do |intake|
      SendRejectResolutionReminderNotificationJob.perform_later(intake)
    end
  end

  def intakes_to_send_message_to
    ny_intakes = StateFileNyIntake.joins(efile_submissions: :efile_submission_transitions)
                                  .where(efile_submission_transitions: { to_state: 'notified_of_rejection' })
                                  .where.not(id: StateFileNyIntake.joins(efile_submissions: :efile_submission_transitions)
                                                                  .where(efile_submission_transitions: { to_state: 'accepted' })
                                                                  .select(:id))
                                  .distinct

    az_intakes = StateFileAzIntake.joins(efile_submissions: :efile_submission_transitions)
                                  .where(efile_submission_transitions: { to_state: 'notified_of_rejection' })
                                  .where.not(id: StateFileAzIntake.joins(efile_submissions: :efile_submission_transitions)
                                                                  .where(efile_submission_transitions: { to_state: 'accepted' })
                                                                  .select(:id))
                                  .distinct

    ny_intakes.to_a + az_intakes.to_a
  end
end
