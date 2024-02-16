class SendAcceptedRejectedNotificationJob < ApplicationJob
  def perform(submission_ids)
    submission_ids.each do |id|
      send_notification(id)
    end
  end

  def send_notification(efile_submission_id)
    submission = EfileSubmission.for_state_filing.find(efile_submission_id)
    if submission.nil?
      Rails.logger.error("*****Error: No efile submission found with id #{efile_submission_id}")
      return
    end

    messaging_service = StateFile::AfterTransitionMessagingService.new(submission)

    case submission.current_state
    when "accepted"
      message = messaging_service.send_efile_submission_accepted_message
      Rails.logger.info("*****Sent accepted message to EfileSubmission ##{efile_submission_id}") if message.present?
    when "rejected"
      message = messaging_service.send_efile_submission_rejected_message
      Rails.logger.info("*****Sent rejected message to EfileSubmission ##{efile_submission_id}") if message.present?
    else
      Rails.logger.error("*****Current state '#{submission.current_state}' doesn't qualify")
    end

    Rails.logger.error("*********No message sent for EfileSubmission ##{efile_submission_id}") unless message
    Rails.logger.info("*********StateFileNotificationEmail ##{message.first.id} created") if message.present?
  end

  def priority
    PRIORITY_LOW
  end
end
