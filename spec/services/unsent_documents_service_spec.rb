require "rails_helper"

describe UnsentDocumentsService do
  let(:service) {described_class.new}

  describe "#detect_unsent_docs_and_notify" do
    let(:fake_dogapi) {instance_double(Dogapi::Client, emit_point: nil)}
    let(:fake_zendesk_service) {instance_double(ZendeskIntakeService)}
    let!(:intake_docs_sent) {create :intake, intake_ticket_id: 1}
    let!(:intake_docs_not_sent) {create :intake, intake_ticket_id: 2}
    let!(:intake_new_doc) {create :intake, intake_ticket_id: 3}
    let!(:document1) {create :document, :with_upload, intake: intake_docs_sent, zendesk_ticket_id: 1234, created_at: 2.hours.ago}
    let!(:document2) {create :document, :with_upload, intake: intake_docs_not_sent, zendesk_ticket_id: nil, created_at: 2.hours.ago}
    let!(:document3) {create :document, :with_upload, intake: intake_docs_not_sent, zendesk_ticket_id: nil, created_at: 2.hours.ago}
    let!(:document4) {create :document, :with_upload, intake: intake_new_doc, zendesk_ticket_id: nil, created_at: 3.minutes.ago}

    before do
      allow(ZendeskIntakeService).to receive(:new).and_return(fake_zendesk_service)
      allow(fake_zendesk_service).to receive(:append_comment_to_ticket)
      allow(fake_zendesk_service).to receive(:get_ticket).and_return(fake_ticket)

      DatadogApi.configure do |c|
        c.enabled = true
        c.namespace = "test.dogapi"
      end
      allow(Dogapi::Client).to receive(:new).and_return(fake_dogapi)
    end

    after do
      DatadogApi.instance_variable_set("@dogapi_client", nil)
    end

    context "when the ticket is not closed" do
      let(:fake_ticket) {double(:ticket, status: "open", id: intake_docs_not_sent.intake_ticket_id)}

      it "checks each intake for unsent documents and notifies Zendesk if any are found" do
        service.detect_unsent_docs_and_notify

        comment = <<~BODY
          New client documents are available to view: #{zendesk_ticket_url(id: intake_docs_not_sent.intake_ticket_id)}
          Files uploaded:
          * picture_id.jpg (W-2)
          * picture_id.jpg (W-2)
        BODY

        expect(fake_zendesk_service).to have_received(:append_comment_to_ticket).with(
          ticket_id: intake_docs_not_sent.intake_ticket_id,
          comment: comment
        )

        expect(document2.reload.zendesk_ticket_id).to eq intake_docs_not_sent.intake_ticket_id
        expect(document3.reload.zendesk_ticket_id).to eq intake_docs_not_sent.intake_ticket_id

        expect(Dogapi::Client).to have_received(:new).once
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.cronjob.documents.unsent.detect_and_notify', 1, {:tags => ["env:" + Rails.env], :type => "count"})
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.ticket.docs.unsent.tickets_updated', 1, {:tags => ["env:" + Rails.env], :type => "gauge"})
        expect(fake_dogapi).to have_received(:emit_point).once.with('test.dogapi.zendesk.ticket.docs.unsent.ticket_updated.document_count', 2, {:tags => ["env:" + Rails.env], :type => "gauge"})
      end

      it "does not notify about sent docs" do
        service.detect_unsent_docs_and_notify

        expect(fake_zendesk_service).not_to have_received(:append_comment_to_ticket).with(hash_including(ticket_id: intake_docs_sent.intake_ticket_id))
        expect(fake_zendesk_service).not_to have_received(:append_comment_to_ticket).with(hash_including(comment: /#{zendesk_ticket_url(id: intake_docs_sent.intake_ticket_id)}/))
      end

      it "creates a client effort when a notification is sent" do
        expect {
          service.detect_unsent_docs_and_notify
        }.to change(ClientEffort, :count).by(1)

        client_effort = ClientEffort.last
        expect(client_effort.effort_type_uploaded_docs?).to eq true
        expect(client_effort.intake).to eq intake_docs_not_sent
        expect(client_effort.ticket_id).to eq intake_docs_not_sent.intake_ticket_id
        expect(client_effort.made_at).to be_within(1.second).of(document2.created_at)
      end

      it "does not notify about or update unsent docs that are less than 15 minutes old" do
        service.detect_unsent_docs_and_notify

        comment_not_sent = <<~BODY
          New client documents are available to view: #{zendesk_ticket_url(id: intake_new_doc.intake_ticket_id)}
          Files uploaded:
          * picture_id.jpg (W-2)
        BODY

        expect(fake_zendesk_service).not_to have_received(:append_comment_to_ticket).with(
          ticket_id: intake_new_doc.intake_ticket_id,
          comment: comment_not_sent
        )

        expect(document4.reload.zendesk_ticket_id).to be_nil
      end
    end

    context "when the ticket is closed" do
      let(:fake_ticket) {double(:ticket, status: "closed")}

      it "does not append a comment or update the documents" do
        service.detect_unsent_docs_and_notify

        expect(fake_zendesk_service).not_to have_received(:append_comment_to_ticket)

        expect(document2.reload.zendesk_ticket_id).to be_nil
        expect(document3.reload.zendesk_ticket_id).to be_nil
      end
    end
  end
end