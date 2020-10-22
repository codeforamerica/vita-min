class MailgunWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_mailgun_params

  def create_incoming_email
    # Mailgun param documentation:
    #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
    sender_email = params["sender"]
    client = Client.where(email_address: sender_email).first
    unless client.present?
      client = Client.create!(email_address: sender_email, intake: Intake.create)
    end
    contact_record = IncomingEmail.create!(
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

    params.each_key do |key|
      next unless /^attachment-\d+$/.match?(key)

      attachment = params[key]
      if FileTypeAllowedValidator::VALID_MIME_TYPES.include? attachment.content_type
        contact_record.documents.attach(
          io: attachment,
          filename: attachment.original_filename,
          content_type: attachment.content_type,
          identify: false # false = don't infer content type from extension
        )
      else
        io = StringIO.new <<~TEXT
          Unusable file with unknown or unsupported file type.
          File name: #{attachment.original_filename}
          File type: #{attachment.content_type}
        TEXT
        contact_record.documents.attach(
          io: io,
          filename: "invalid-" + attachment.original_filename,
          content_type: "text/plain;charset=UTF-8",
          identify: false
        )
      end
    end

    ClientChannel.broadcast_contact_record(contact_record)
    head :ok
  end

  private

  def validate_mailgun_params
    return head 403 unless MailgunService.valid_post?(params)
  end
end