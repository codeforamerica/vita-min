class SendAssignmentEmailJob < ApplicationJob
  queue_as :default
  retry_on Mailgun::CommunicationError

  def perform(assignment_email_id)
    assignment_email = AssignmentEmail.find(assignment_email_id)
    mailer_response = UserMailer.assignment_email(assignment_email).deliver_now
    assignment_email.update(message_id: mailer_response.message_id, sent_at: DateTime.current)
  end

  def priority
    low_priority
  end
end
