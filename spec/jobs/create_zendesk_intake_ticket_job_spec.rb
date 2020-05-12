require "rails_helper"

RSpec.describe CreateZendeskIntakeTicketJob, type: :job do
  let(:fake_zendesk_intake_service) { double(ZendeskIntakeService) }
  let(:intake) { create :intake, intake_ticket_id: intake_ticket_id, intake_ticket_requester_id: intake_requester_id }

  # clean start
  # these fields are the intake fields
  let(:intake_requester_id) { nil }
  let(:intake_ticket_id) { nil }
  # these fields are returned by zendesk service
  let(:new_requester_id) { nil }
  let(:new_ticket_id) { nil }

  describe "#perform" do
    context "without errors" do
      before do
        allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
        allow(fake_zendesk_intake_service).to receive(:assign_requester).and_return(new_requester_id)
        allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(new_ticket_id)
        described_class.perform_now(intake.id)
      end

      context "without a requester or ticket" do
        let(:intake_requester_id) { nil }
        let(:intake_ticket_id) { nil }
        let(:new_requester_id) { rand(640_000 ) }
        let(:new_ticket_id) { rand(640_000 ) }

        it "creates a new intake ticket in Zendesk and saves IDs to the intake" do
          intake.reload
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
          intake.reload
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
          intake.reload
          expect(ZendeskIntakeService).not_to have_received(:new)
          expect(fake_zendesk_intake_service).not_to have_received(:assign_requester)
          expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
        end
      end
    end
  end

  describe "#perform unexpectedly" do
    context "when unable to create a ticket requester" do
      before do
        allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
        allow(fake_zendesk_intake_service).to receive(:assign_requester) { nil }
        allow(fake_zendesk_intake_service).to receive(:create_intake_ticket) { nil }
        described_class.perform_now(intake.id)
      end

      it "does not try to create a ticket" do
        expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
      end
    end
  end
end
