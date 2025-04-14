class MissingAttachmentError < StandardError; end

class ProcessTextMessageAttachmentsJob < ApplicationJob
  retry_on MissingAttachmentError

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
