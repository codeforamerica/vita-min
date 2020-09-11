class MailgunWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_mailgun_params

  def create_incoming_email
    # Mailgun param documentation:
    #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
    sender_email = params["sender"]
    client = Client.where(email_address: sender_email).first
    unless client.present?
      client = Client.create!(email_address: sender_email)
    end
    IncomingEmail.create!(
      client: client,
      received_at: DateTime.now,
      sender: sender_email,
      to: params["To"],
      from: params["From"],
      recipient: params["recipient"],
      subject: params["subject"],
      body_html: params["body-html"],
      body_plain: params["body-plain"],
      stripped_html: params["stripped-html"],
      stripped_text: params["stripped-text"],
      stripped_signature: params["stripped-signature"],
      received: params["Received"],
      attachment_count: params["attachment-count"],
    )
    head :ok
  end

  private

  def validate_mailgun_params
    return head 403 unless MailgunService.valid_post?(params)
  end
end