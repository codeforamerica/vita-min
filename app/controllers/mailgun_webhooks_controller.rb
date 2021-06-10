class MailgunWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_mailgun_request

  def create_incoming_email
    # Mailgun param documentation:
    #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
    DatadogApi.increment("mailgun.incoming_emails.received")
    sender_email = params["sender"]
    clients = Client.joins(:intake).where(intakes: { email_address: sender_email})
    client_count = clients.count
    if client_count == 0
      DatadogApi.increment("mailgun.incoming_emails.client_not_found")
      clients = [Client.create!(
        intake: Intake.create!(
          email_address: sender_email,
          visitor_id: SecureRandom.hex(26),
          email_notification_opt_in: "yes",
        ),
        vita_partner: VitaPartner.client_support_org,
      )]
    elsif client_count == 1
      DatadogApi.increment("mailgun.incoming_emails.client_found")
    elsif client_count > 1
      DatadogApi.increment("mailgun.incoming_emails.client_found_multiple")
    end

    clients.each do |client|
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
      processed_attachments = []
      params.each_key do |key|
        next unless /^attachment-\d+$/.match?(key)

        attachment = params[key]
        attachment.tempfile.seek(0) # just in case we read the same file for multiple clients
        size = attachment.tempfile.size

        processed_attachments <<
          if (FileTypeAllowedValidator::VALID_MIME_TYPES.include? attachment.content_type) && (size > 0)
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
              File size: #{attachment.size} bytes
            TEXT
            {
                io: io,
                filename: "invalid-#{attachment.original_filename}.txt",
                content_type: "text/plain;charset=UTF-8",
                identify: false
            }
          end
      end

      processed_attachments.each do |upload_params|
        client.documents.create!(
          document_type: DocumentTypes::EmailAttachment.key,
          contact_record: contact_record,
          upload: upload_params
        )

      end

      IntercomService.create_intercom_message_from_email(contact_record, inform_of_handoff: true) if client.forward_message_to_intercom?

      ClientChannel.broadcast_contact_record(contact_record)
    end

    head :ok
  end

  def update_outgoing_email_status
    email_to_update = OutgoingEmail.find_by(message_id: params.dig("event-data", "message", "headers", "message-id"))
    DatadogApi.increment("mailgun.update_outgoing_email_status.email_not_found") if email_to_update.nil?
    email_to_update&.update(mailgun_status: params.dig("event-data", "event"))

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
