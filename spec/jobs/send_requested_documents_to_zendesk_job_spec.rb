require "rails_helper"

RSpec.describe SendRequestedDocumentsToZendeskJob, type: :job do
  let(:fake_service) { instance_double(ZendeskFollowUpDocsService) }

  before do
    allow(ZendeskFollowUpDocsService).to receive(:new).and_return fake_service
    allow(fake_service).to receive(:send_requested_docs).and_return(true)
  end

  describe "#perform" do
    let(:intake) do
      create :intake
    end

    before do
      described_class.perform_now(intake.id)
    end

    it "sends the intake pdf and all of the docs as comments on the intake ticket" do
      expect(ZendeskFollowUpDocsService).to have_received(:new).with(intake)
      expect(fake_service).to have_received(:send_requested_docs)
    end
  end
end
