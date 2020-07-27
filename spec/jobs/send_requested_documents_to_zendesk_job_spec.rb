require "rails_helper"

RSpec.describe SendRequestedDocumentsToZendeskJob, type: :job do
  let(:fake_service) { instance_double(ZendeskFollowUpDocsService) }

  before do
    allow(ZendeskFollowUpDocsService).to receive(:new).and_return fake_service
    allow(fake_service).to receive(:send_requested_docs).and_return(true)
  end

  describe "#perform" do
    let(:intake) do
      create :intake, intake_ticket_id: rand(2**(7 * 8))
    end

    context "without errors" do
      it "sends the intake pdf and all of the docs as comments on the intake ticket" do
        described_class.perform_now(intake.id)
        expect(ZendeskFollowUpDocsService).to have_received(:new).with(intake)
        expect(fake_service).to have_received(:send_requested_docs)
      end

      it "creates a new client effort" do
        expect {
          described_class.perform_now(intake.id)
        }.to change(ClientEffort, :count).by(1)

        client_effort = ClientEffort.last
        expect(client_effort.effort_type).to eq "uploaded_requested_docs"
        expect(client_effort.intake).to eq intake
        expect(client_effort.ticket_id).to eq intake.intake_ticket_id
        expect(client_effort.made_at).to be_within(1.second).of(Time.now)
      end
    end

    it_behaves_like "catches exceptions with raven context", :send_requested_docs do
      let(:fake_zendesk_intake_service) { fake_service }
    end
    it_behaves_like "a ticket-dependent job", ZendeskFollowUpDocsService
  end
end
