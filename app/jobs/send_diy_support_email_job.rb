class SendDiySupportEmailJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default
  retry_on Mailgun::CommunicationError

  def perform(diy_intake)
    diy_intake_email = DiyIntakeEmail.create(diy_intake: diy_intake)
    mailer_response = DiyIntakeEmailMailer.message(diy_intake_email: diy_intake_email).deliver_now
    diy_intake_email.update(message_id: mailer_response.message_id, sent_at: DateTime.now)
  end
end
