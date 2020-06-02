require "rails_helper"

describe ZendeskFollowUpDocsService do
  let(:intake) { create :intake, intake_ticket_id: 34 }
  let(:service) { described_class.new(intake) }
  let(:fake_dogapi) { instance_double(Dogapi::Client, emit_point: nil) }

  before do
    DatadogApi.configure do |c|
      c.enabled = true
      c.namespace = "test.dogapi"
    end
    allow(Dogapi::Client).to receive(:new).and_return(fake_dogapi)
  end

  describe "#send_requested_docs" do
    let!(:requested_docs) do
      [
        create(:document, :with_upload, intake: intake, document_type: "Requested Later"),
        create(:document, :with_upload, intake: intake, document_type: "Requested Later"),
        create(:document, :with_upload, intake: intake, document_type: "Requested Later")
      ]
    end
    let!(:other_doc) do
      create(:document, :with_upload, intake: intake, document_type: "Other")
    end
    let!(:older_doc) do
      create :document, :with_upload, intake: intake, document_type: "Requested Later", zendesk_ticket_id: 1234
    end
    let(:output) { true }

    before do
      DatadogApi.instance_variable_set("@dogapi_client", nil)
      allow(service).to receive(:append_comment_to_ticket).and_return(output)
    end

    it "lists each requested doc in the comment and adds portal link to the ticket" do
      result = service.send_requested_docs
      expect(result).to eq true

      expect(service).to have_received(:append_comment_to_ticket).with(
        ticket_id: 34,
        fields: {
          EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS => zendesk_ticket_url(34)
        },
        comment: <<~DOCS
          The client added requested follow-up documents:
          * #{requested_docs[0].upload.filename}
          * #{requested_docs[1].upload.filename}
          * #{requested_docs[2].upload.filename}

          View all client documents here:
          #{zendesk_ticket_url(34)}
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

    it "sends a datadog metric" do
      service.send_requested_docs

      expect(Dogapi::Client).to have_received(:new).once
      expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.ticket.docs.requested.sent', 1, {:tags => ["env:"+Rails.env], :type => "count"})
    end

    context "when the user has not uploaded any documents" do
      before do
        DatadogApi.instance_variable_set("@dogapi_client", nil)
        intake.documents.destroy_all
      end

      it "does not update zendesk" do
        service.send_requested_docs

        expect(service).not_to have_received(:append_comment_to_ticket)
      end

      it "does not send a datadog metric" do
        service.send_requested_docs

        expect(Dogapi::Client).not_to have_received(:new)
        expect(fake_dogapi).not_to have_received(:emit_point)
      end
    end
  end
end
