class MailgunWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :authenticate_mailgun_request

  REGEX_FROM_ENVELOPE = /.*\<(?<address>(.*))>/.freeze

  def create_incoming_email
    logo_bytes = File.binread(Rails.root.join('public', 'images', 'logo.png'))

    # Mailgun param documentation:
    #   https://documentation.mailgun.com/en/latest/user_manual.html#parsed-messages-parameters
    DatadogApi.increment("mailgun.incoming_emails.received")
    sender_email_address = parse_valid_email_address(from: params["from"], sender: params["sender"])
    clients = Client.joins(:intake).where(intakes: { email_address: sender_email_address })
    client_count = clients.count
    if sender_email_address.is_FYST?
      # Create incoming EMail for FYST
    elsif client_count.zero?
      archived_intake = most_recent_intake(sender_email_address)
      if archived_intake.present?
        locale = archived_intake.locale || "en"
        archived_intake.client.outgoing_emails.create!(
          to: sender_email_address,
          subject: AutomatedMessage::UnmonitoredReplies.new.email_subject(locale: locale),
          body: AutomatedMessage::UnmonitoredReplies.new.email_body(locale: locale, support_email: Rails.configuration.email_from[:support][:gyr])
        )
        DatadogApi.increment("mailgun.outgoing_emails.sent_replies_not_monitored")
      else
        DatadogApi.increment("mailgun.incoming_emails.client_not_found")

        IntercomService.create_message(
          client: nil,
          phone_number: nil,
          email_address: sender_email_address,
          body: params["stripped-text"] || params["body-plain"],
          has_documents: false
        )
      end

      return head :ok
    elsif client_count == 1
      DatadogApi.increment("mailgun.incoming_emails.client_found")
    elsif client_count > 1
      DatadogApi.increment("mailgun.incoming_emails.client_found_multiple")
    end

    clients.each do |client|
      contact_record = IncomingEmail.create!(
        client: client,
        received_at: DateTime.now,
        sender: sender_email_address,
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
        next if attachment.original_filename.ends_with? '.mail'

        attachment.tempfile.seek(0) # allows re-reading the file for multiple clients
        size = attachment.tempfile.size
        if size == logo_bytes.size
          matches_logo = attachment.tempfile.read == logo_bytes
          attachment.tempfile.seek(0)
          next if matches_logo
        end

        processed_attachments <<
          if (FileTypeAllowedValidator.mime_types(Document).include? attachment.content_type) && (size > 0)
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

      TransitionNotFilingService.run(client)

      has_documents = (contact_record.attachment_count || 0) != 0
      if client.forward_message_to_intercom?
        if contact_record.body.blank? && !has_documents
          Sentry.capture_message("IncomingEmail #{contact_record.id} does not have a body or any attachments.")
        else
          Sentry.with_scope do |scope|
            scope.set_tags(
              incoming_email_id: contact_record.id,
              resolution_steps: "Forwarding the message to intercom failed, so manually re-run the code in this block on rails c."
            ) # sometimes create_message has been flaky
            IntercomService.create_message(
              phone_number: nil,
              client: contact_record.client,
              body: contact_record.body,
              email_address: contact_record.sender,
              has_documents: has_documents
            )
            IntercomService.inform_client_of_handoff(send_sms: false, client: contact_record.client, send_email: true)
          end
        end
      end

      ClientChannel.broadcast_contact_record(contact_record)
    end

    head :ok
  end

  def update_outgoing_email_status
    message_id = params.dig("event-data", "message", "headers", "message-id")
    email_to_update = (
      OutgoingEmail.find_by(message_id: message_id) ||
        VerificationEmail.find_by(mailgun_id: message_id) ||
        OutgoingMessageStatus.find_by(message_id: message_id, message_type: :email) ||
        StateFileNotificationEmail.find_by(message_id: message_id)
    )
    DatadogApi.increment("mailgun.update_outgoing_email_status.email_not_found") if email_to_update.nil?
    status_key =
      if email_to_update.is_a?(OutgoingMessageStatus)
        :delivery_status
      else
        :mailgun_status
      end
    email_to_update&.update(status_key => params.dig("event-data", "event"))

    head :ok
  end

  private

  def parse_valid_email_address(from:, sender:)
    if REGEX_FROM_ENVELOPE.match?(from)
      provided_address = REGEX_FROM_ENVELOPE.match(from).named_captures["address"]
      approved_domain = sender.split("@")[1]
      if provided_address&.ends_with?("@#{approved_domain}")
        provided_address
      else
        sender
      end
    else
      sender
    end
  end

  def authenticate_mailgun_request
    authenticate_or_request_with_http_basic do |name, password|
      expected_name = EnvironmentCredentials.dig(:mailgun, :basic_auth_name)
      expected_password = EnvironmentCredentials.dig(:mailgun, :basic_auth_password)
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end

  def most_recent_intake(email_address)
    Archived::Intake2021.where(email_address: email_address).first
  end
end
