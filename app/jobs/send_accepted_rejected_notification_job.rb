class SendAcceptedRejectedNotificationJob < ApplicationJob
  def perform(submission_ids)
    submission_ids.each do |id|
      send_notification(id)
    end
  end

  def send_notification(efile_submission_id)
    submission = EfileSubmission.for_state_filing.find(efile_submission_id)
    if submission.nil?
      puts "*****Error: No efile submission found with id #{efile_submission_id}"
      return
    end

    messaging_service = StateFile::AfterTransitionMessagingService.new(submission)

    case submission.current_state
    when "accepted"
      messaging_service.send_efile_submission_accepted_message
      puts "*****Sent accepted message to efile submission #{efile_submission_id}"
    when "rejected"
      messaging_service.send_efile_submission_rejected_message
      puts "*****Sent rejected message to efile submission #{efile_submission_id}"
    else
      puts "*****Error: current state '#{submission.current_state}' doesn't qualify"
    end
  end

  def priority
    PRIORITY_LOW
  end
end
