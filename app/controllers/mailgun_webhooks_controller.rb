class MailgunWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_mailgun_request

  def create_incoming_email
    # Mailgun param documentation:
    #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
    sender_email = params["sender"]
    client = Intake.where(email_address: sender_email).first&.client
    unless client.present?
      client = Client.create!(intake: Intake.create!(email_address: sender_email, visitor_id: SecureRandom.hex(26)))
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

      upload_params =
        if FileTypeAllowedValidator::VALID_MIME_TYPES.include? attachment.content_type
          {
            io: attachment,
            filename: attachment.original_filename,
            content_type: attachment.content_type,
            identify: false # false = don't infer content type from extension
          }
        else
          io = StringIO.new <<~TEXT
            Unusable file with unknown or unsupported file type.
            File name:'#{attachment.original_filename}'
            File type:'#{attachment.content_type}'
          TEXT
          {
            io: io,
            filename: "invalid-#{attachment.original_filename}.txt",
            content_type: "text/plain;charset=UTF-8",
            identify: false
          }
        end

      client.documents.create!(
        document_type: DocumentTypes::EmailAttachment.key,
        contact_record: contact_record,
        upload: upload_params
      )
    end

    ClientChannel.broadcast_contact_record(contact_record)
    head :ok
  end

  private

  def authenticate_mailgun_request
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = EnvironmentCredentials.dig(:mailgun, :basic_auth_name)
      expected_password = EnvironmentCredentials.dig(:mailgun, :basic_auth_password)
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
