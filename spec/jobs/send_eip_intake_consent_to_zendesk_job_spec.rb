require "rails_helper"

RSpec.describe SendEipIntakeConsentToZendeskJob, type: :job do
  let(:service) { instance_double(Zendesk::EipService) }

  describe "#perform" do
    let(:intake_ticket_id) { 2 }
    let(:intake) do
      create :intake,
             :eip_only,
             intake_ticket_id: intake_ticket_id
    end

    before do
      allow(Zendesk::EipService).to receive(:new).and_return(service)
      allow(service).to receive(:send_consent_to_zendesk)
    end

    it "calls the service method to update the Zendesk ticket" do
      described_class.perform_now(intake.id)
      expect(service).to have_received(:send_consent_to_zendesk)
    end
  end
end
