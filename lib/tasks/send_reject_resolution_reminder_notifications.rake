namespace :send_reject_resolution_reminder_notifications do
  desc 'Send reject resolution reminder notifications'
  task 'send' => :environment do
    intakes_to_send_message_to.each do |intake|
      StateFile::SendRejectResolutionReminderNotificationJob.perform_later(intake)
    end
  end

  def intakes_to_send_message_to
    StateFile::StateInformationService.state_intake_classes.flat_map do |class_object|
      class_object.joins(efile_submissions: :efile_submission_transitions)
                       .where(efile_submission_transitions: { to_state: 'notified_of_rejection' })
                       .where.not(id: class_object.joins(efile_submissions: :efile_submission_transitions)
                                                       .where(efile_submission_transitions: { to_state: 'accepted' })
                                                       .select(:id))
                       .distinct.to_a
    end
  end
end
