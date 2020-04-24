require "rails_helper"

RSpec.describe ZendeskRequestedDocsLinkBackfill do
  describe '.update' do
    let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }
    let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket) }
    let(:intake_properties) { {} }
    let!(:intakes) do
      [
        create(:intake, **intake_properties),
      ]
    end

    before do
      allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
      allow(fake_zendesk_intake_service)
        .to receive(:attach_requested_docs_link)
        .with(fake_zendesk_ticket)
      allow(fake_zendesk_intake_service)
        .to receive(:get_ticket)
        .and_return(fake_zendesk_ticket)
    end

    describe "for an intake with an existing requested docs token" do
      let(:intake_properties) do
        {
          requested_docs_token: "t0k3n",
          intake_ticket_id: "123",
        }
      end

      it "doesn't do anything" do
        described_class.update
        expect(fake_zendesk_intake_service).not_to have_received(:get_ticket)
      end
    end

    describe "for an intake with no intake ticket id" do
      let(:intake_properties) do
        {
          intake_ticket_id: nil,
        }
      end

      it "doesn't do anything" do
        described_class.update
        expect(fake_zendesk_intake_service).not_to have_received(:get_ticket)
      end
    end

    describe "for an intake with no requested docs token" do
      let(:intake_properties) do
        {
          intake_ticket_id: "123",
        }
      end

      it "backfills the field as we expect" do
        described_class.update
        expect(fake_zendesk_intake_service).to have_received(:get_ticket)
        expect(fake_zendesk_intake_service).to have_received(:attach_requested_docs_link)
          .with(fake_zendesk_ticket)
      end
    end
  end
end
