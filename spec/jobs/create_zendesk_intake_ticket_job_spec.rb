require "rails_helper"

RSpec.describe CreateZendeskIntakeTicketJob, type: :job do
  let(:fake_zendesk_intake_service) { double(ZendeskIntakeService) }
  let(:email_address) { "filer@example.horse" }
  let(:intake) { create :intake, intake_ticket_id: intake_ticket_id, intake_ticket_requester_id: intake_requester_id, email_address: email_address }

  # clean start
  # these fields are the intake fields
  let(:intake_requester_id) { nil }
  let(:intake_ticket_id) { nil }
  # these fields are returned by zendesk service
  let(:new_requester_id) { nil }
  let(:new_ticket_id) { nil }

  describe "#perform_later" do
    context "when it is in enqueued", active_job: true do
      it "sets the intake's has_enqueued_ticket_creation property" do
        expect do
          described_class.perform_later(intake.id)
        end.to change {
          intake.reload.has_enqueued_ticket_creation
        }.from(false).to(true)
      end
    end
  end

  describe "#perform" do
    before do
      allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
      allow(fake_zendesk_intake_service).to receive(:assign_requester).and_return(new_requester_id)
      allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(new_ticket_id)
    end

    context "without a requester or ticket" do
      let(:intake_requester_id) { nil }
      let(:intake_ticket_id) { nil }
      let(:new_requester_id) { rand(640_000 ) }
      let(:new_ticket_id) { rand(640_000 ) }

      it "creates a new intake ticket in Zendesk and saves IDs to the intake" do
        described_class.perform_now(intake.id)

        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:assign_requester).with(no_args)
        expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
      end
    end

    context "with a requester but no ticket" do
      let(:intake_requester_id) { 32 }
      let(:intake_ticket_id) { nil }
      let(:new_requester_id) { intake_requester_id }

      it "creates a ticket" do
        described_class.perform_now(intake.id)

        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
      end
    end

    context "with a requester and ticket" do
      let(:intake_requester_id) { 32 }
      let(:intake_ticket_id) { 7 }
      let(:new_requester_id) { intake_requester_id }
      let(:new_ticket_id) { intake_ticket_id }

      it "does not call the zendesk service" do
        described_class.perform_now(intake.id)

        expect(ZendeskIntakeService).not_to have_received(:new)
        expect(fake_zendesk_intake_service).not_to have_received(:assign_requester)
        expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
      end
    end

    context "when the client has other pre-existing tickets" do
      context "client has a diy intake ticket" do
        let(:diy_ticket_id) { 12 }
        let(:new_ticket_id) { 33 }
        let!(:diy_intake) { create :diy_intake, email_address: email_address, ticket_id: diy_ticket_id }
        let(:fake_ticket) { double(ZendeskAPI::Ticket, id: new_ticket_id) }

        before do
          allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(fake_ticket)
          allow(fake_zendesk_intake_service).to receive(:get_ticket!).and_return(fake_ticket)
          allow(fake_zendesk_intake_service).to receive(:append_comment_to_ticket)
          allow(fake_zendesk_intake_service).to receive(:ticket_url).and_return("https://eitc.zendesk.com/agent/tickets/#{new_ticket_id}")
        end

        it "appends comments to those tickets with link to new ticket" do
          described_class.perform_now(intake.id)

          expect(fake_zendesk_intake_service).to have_received(:append_comment_to_ticket).with(
            ticket_id: diy_ticket_id,
            comment: "This client has a GetYourRefund full service ticket: https://eitc.zendesk.com/agent/tickets/#{new_ticket_id}"
          )
        end
      end

      context "client has an EIP intake ticket" do
        let(:eip_ticket_id) { 222 }
        let(:new_ticket_id) { 33 }
        let(:fake_ticket) { double(ZendeskAPI::Ticket, id: new_ticket_id) }
        let!(:eip_intake) { create :intake, :eip_only, email_address: email_address, intake_ticket_id: eip_ticket_id }

        before do
          allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(fake_ticket)
          allow(fake_zendesk_intake_service).to receive(:get_ticket!).and_return(fake_ticket)
          allow(fake_zendesk_intake_service).to receive(:append_comment_to_ticket)
          allow(fake_zendesk_intake_service).to receive(:ticket_url).and_return("https://eitc.zendesk.com/agent/tickets/#{new_ticket_id}")
        end

        it "appends comments to those tickets with link to new ticket" do
          described_class.perform_now(intake.id)

          expect(fake_zendesk_intake_service).to have_received(:append_comment_to_ticket).with(
            ticket_id: eip_ticket_id,
            comment: "This client has a GetYourRefund full service ticket: https://eitc.zendesk.com/agent/tickets/#{new_ticket_id}"
          )
        end
      end
    end
  end
end
