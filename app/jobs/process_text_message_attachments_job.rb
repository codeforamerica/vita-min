class TwilioMissingAttachmentError < StandardError; end

class ProcessTextMessageAttachmentsJob < ApplicationJob
  retry_on TwilioMissingAttachmentError, attempts: 10
  # Per GYR1-706: "It seems that Twilio sends us S3 URLs for text attachments
  # that haven't been fully processed, because we get 404s when we try to access
  # them. These attachments become accessible at some later point"

  def perform(incoming_text_message_id, client_id, params)
    attachments = TwilioService.new.parse_attachments(params)

    documents = attachments.map do |attachment|
      Document.new(
        client: Client.find(client_id),
        document_type: DocumentTypes::TextMessageAttachment.key,
        upload: {
          io: StringIO.new(attachment[:body]),
          filename: attachment[:filename],
          content_type: attachment[:content_type],
          identify: false
        }
      )
    end

    IncomingTextMessage.find(incoming_text_message_id).update(documents: documents)
  end

  def priority
    PRIORITY_LOW
  end
end
