class SendInternalEmailJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def perform(internal_email)
    mailer_response = internal_email.mail_class.constantize.send(internal_email.mail_method, **internal_email.deserialized_mail_args).deliver_now
    internal_email.create_outgoing_message_status(message_id: mailer_response.message_id, message_type: :email)
  end

  def priority
    PRIORITY_LOW
  end
end
