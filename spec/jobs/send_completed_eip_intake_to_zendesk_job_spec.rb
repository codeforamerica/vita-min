require "rails_helper"

RSpec.describe SendCompletedEipIntakeToZendeskJob, type: :job do
  let(:service) { instance_double(Zendesk::EipService) }

  before do
    allow(Zendesk::EipService).to receive(:new).and_return service
    allow(service).to receive(:send_completed_intake_to_zendesk)
  end

  describe "#perform" do
    context "when the comment has not been appended" do
      let(:intake) { create :intake, intake_ticket_id: 3 }

      it "sends the intake pdf and all of the docs as comments on the intake ticket" do
        described_class.perform_now(intake.id)
        expect(service).to have_received(:send_completed_intake_to_zendesk)
      end
    end
  end
end
