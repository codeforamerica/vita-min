require "rails_helper"

describe ProcessTextMessageAttachmentsJob do
  describe "#perform" do
    it "creates a document for each attachment" do
      client = create(:client)
      incoming_text_message = create(:incoming_text_message)
      params = { some: "params" }
      parsed_attachments = [
        { content_type: "image/jpeg", filename: "some-type-of-image.jpg", body: "image file contents" },
        { content_type: "application/pdf", filename: "some-type-of-file.pdf", body: "pdf file contents" }
      ]

      allow_any_instance_of(TwilioService)
        .to receive(:parse_attachments)
              .with(params)
              .and_return parsed_attachments

      expect {
        described_class.perform_now(incoming_text_message.id, client.id, params)
      }.to change(Document, :count).by(2)

      doc1, doc2 = Document.last(2)
      expect(incoming_text_message.documents).to match_array([doc1, doc2])
      expect(doc1.client).to eq(client)
      expect(doc1.document_type).to eq("Text Message Attachment")
      expect(doc1.upload.content_type).to eq("image/jpeg")
      expect(doc1.upload.filename).to eq("some-type-of-image.jpg")
      expect(doc1.upload.blob.download).to eq("image file contents")

      expect(doc2.client).to eq(client)
      expect(doc2.document_type).to eq("Text Message Attachment")
      expect(doc2.upload.content_type).to eq("application/pdf")
      expect(doc2.upload.filename).to eq("some-type-of-file.pdf")
      expect(doc2.upload.blob.download).to eq("pdf file contents")
    end

    it "retries the job when the attachment body is nil" do
      client_id = create(:client).id
      incoming_text_message_id = create(:incoming_text_message).id
      params = {
        "NumMedia" => "1",
        "MediaContentType0" => "text/plain",
        "MediaUrl0" => { filename: nil, body: nil },
      }

      expect {
        described_class.perform_now(incoming_text_message_id, client_id, params)
      }.to have_enqueued_job(described_class).with(incoming_text_message_id, client_id, params)
                                             .and not_change(Document, :count)
    end
  end
end
