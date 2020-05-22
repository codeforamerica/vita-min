require "rails_helper"

RSpec.describe CreateZendeskDiyIntakeTicketJob, type: :job do
  let(:fake_zendesk_intake_service) { double(ZendeskDiyIntakeService) }
  let(:diy_intake) { create(:diy_intake) }

  describe "#perform" do
    context "without errors" do
      it "assigns a requester and creates a diy_intake ticket" do
        expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
          .and_return(fake_zendesk_intake_service)
        expect(fake_zendesk_intake_service).to receive(:assign_requester)
        expect(fake_zendesk_intake_service).to receive(:create_diy_intake_ticket)
        described_class.perform_now(diy_intake.id)
      end
    end

    context "with errors" do
      context "when an error is raised while assigning requester" do
        before do
          expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
            .and_return(fake_zendesk_intake_service)
          expect(fake_zendesk_intake_service)
            .to receive(:assign_requester)
            .and_raise(ZendeskServiceHelper::ZendeskServiceError)
        end

        it "raises an error and does not try to create a ticket" do
          expect(fake_zendesk_intake_service).not_to receive(:create_diy_intake_ticket)
          expect { described_class.perform_now(diy_intake.id) }
            .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
        end
      end

      context "when an error is raised while creating a ticket" do
        before do
          expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
            .and_return(fake_zendesk_intake_service)
          expect(fake_zendesk_intake_service).to receive(:assign_requester)
          expect(fake_zendesk_intake_service)
            .to receive(:create_diy_intake_ticket)
            .and_raise(ZendeskServiceHelper::ZendeskServiceError)
        end

        it "let's the error be raised" do
          expect { described_class.perform_now(diy_intake.id) }
            .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
        end
      end
    end
  end
end
