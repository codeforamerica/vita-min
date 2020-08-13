require "rails_helper"

RSpec.describe CreateZendeskEipIntakeTicketJob, type: :job do
  describe "#perform" do
    let(:intake) {create :intake, :eip_only}
    let(:fake_zendesk_intake_service) { double(Zendesk::EipService) }

    before do
      allow(fake_zendesk_intake_service).to receive(:assign_requester)
      allow(Zendesk::EipService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
      allow(fake_zendesk_intake_service).to receive(:create_eip_ticket)
    end

    it "uses the service to assign a requester and create a ticket" do
      described_class.perform_now(intake.id)

      expect(Zendesk::EipService).to have_received(:new).with(intake)
      expect(fake_zendesk_intake_service).to have_received(:assign_requester).with(no_args)
      expect(fake_zendesk_intake_service).to have_received(:create_eip_ticket).with(no_args)
    end
  end
end
