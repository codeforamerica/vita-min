class SendOutgoingEmailJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_email_id)
    outgoing_email = OutgoingEmail.find(outgoing_email_id)
    mailer_response = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email).deliver_now
    outgoing_email.update(message_id: mailer_response.message_id, sent_at: DateTime.now)
  end

  def priority
    low_priority
  end
end
