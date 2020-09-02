require "rails_helper"

RSpec.describe CreateZendeskDiyIntakeTicketJob, type: :job do
  let(:fake_zendesk_diy_intake_service) { double(ZendeskDiyIntakeService) }
  let(:email_address) { "my_email@ofcourse.horse" }
  let(:diy_intake) { create :diy_intake, email_address: email_address }
  let(:diy_ticket_id) { "123" }
  let(:fake_diy_ticket) { double(ZendeskAPI::Ticket, id: diy_ticket_id) }

  describe "#perform" do
    context "without errors" do
      before do
        allow(ZendeskDiyIntakeService).to receive(:new).and_return(fake_zendesk_diy_intake_service)
        allow(fake_zendesk_diy_intake_service).to receive(:assign_requester)
        allow(fake_zendesk_diy_intake_service).to receive(:create_diy_intake_ticket).and_return(fake_diy_ticket)
      end

      it "assigns a requester and creates a diy_intake ticket" do
        described_class.perform_now(diy_intake.id)

        expect(ZendeskDiyIntakeService).to have_received(:new).with(diy_intake)
        expect(fake_zendesk_diy_intake_service).to have_received(:assign_requester)
        expect(fake_zendesk_diy_intake_service).to have_received(:create_diy_intake_ticket)
      end

      context "when the user has filled out a full service intake" do
        let(:fake_ticket) { double(ZendeskAPI::Ticket, url: "ticket_url") }
        let(:intake_ticket_id) { 123 }
        let!(:intake) { create :intake, email_address: email_address, intake_ticket_id: intake_ticket_id }

        before do
          allow(fake_zendesk_diy_intake_service).to receive(:append_comment_to_ticket)
        end

        it "appends comment to any full service intake tickets associated with the same email address" do
          described_class.perform_now(diy_intake.id)

          expect(fake_zendesk_diy_intake_service).to have_received(:append_comment_to_ticket).with(
            ticket_id: intake_ticket_id,
            comment: "This client has requested a TaxSlayer DIY link from GetYourRefund.org",
            skip_if_closed: true
          )
        end
      end
    end

    context "with errors", active_job: true do
      context "when an error is raised while assigning requester" do
        before do
          expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
            .and_return(fake_zendesk_diy_intake_service)
          expect(fake_zendesk_diy_intake_service)
            .to receive(:assign_requester)
            .and_raise(ZendeskServiceHelper::ZendeskServiceError)
        end

        it "raises an error and does not try to create a ticket" do
          expect(fake_zendesk_diy_intake_service).not_to receive(:create_diy_intake_ticket)
          expect { described_class.perform_now(diy_intake.id) }
            .to raise_error(ZendeskServiceHelper::ZendeskServiceError)
        end
      end

      context "when an error is raised while creating a ticket" do
        before do
          expect(ZendeskDiyIntakeService).to receive(:new).with(diy_intake)
            .and_return(fake_zendesk_diy_intake_service)
          expect(fake_zendesk_diy_intake_service).to receive(:assign_requester)
          expect(fake_zendesk_diy_intake_service)
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
