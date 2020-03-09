require "rails_helper"

describe ZendeskFollowUpDocsService do
  let(:intake) { create :intake, intake_ticket_id: 34 }
  let(:service) { described_class.new(intake) }

  describe "#send_requested_docs" do
    let!(:requested_docs) do
      [
        create(:document, :with_upload, intake: intake, document_type: "Requested"),
        create(:document, :with_upload, intake: intake, document_type: "Requested")
      ]
    end
    let!(:other_doc) do
      create(:document, :with_upload, intake: intake, document_type: "Other")
    end
    let!(:older_doc) do
      create :document, :with_upload, intake: intake, document_type: "Requested", zendesk_ticket_id: 1234
    end
    let(:output) { true }

    before { allow(service).to receive(:append_multiple_files_to_ticket).and_return(output) }

    it "appends each requested doc to the ticket" do
      result = service.send_requested_docs

      expect(result).to eq true

      expect(service).to have_received(:append_multiple_files_to_ticket).with(
        ticket_id: 34,
        file_list: [
          { filename: "picture_id.jpg", file: instance_of(Tempfile) },
          { filename: "picture_id.jpg", file: instance_of(Tempfile) },
        ],
        comment: <<~DOCS
          The client added requested follow-up documents:
          * #{requested_docs[0].upload.filename}
          * #{requested_docs[1].upload.filename}
        DOCS
      )
    end

    it "sets the zendesk ticket id on each document that is successfully sent" do
      service.send_requested_docs

      requested_docs.each do |doc|
        doc.reload
        expect(doc.zendesk_ticket_id).to eq 34
      end
    end
  end
end
