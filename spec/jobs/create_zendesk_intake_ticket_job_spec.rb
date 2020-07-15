require "rails_helper"

RSpec.describe CreateZendeskIntakeTicketJob, type: :job do
  let(:fake_zendesk_intake_service) { double(ZendeskIntakeService) }
  let(:intake) { create :intake, intake_ticket_id: intake_ticket_id, intake_ticket_requester_id: intake_requester_id, email_address: "filer@example.horse" }

  # clean start
  # these fields are the intake fields
  let(:intake_requester_id) { nil }
  let(:intake_ticket_id) { nil }
  # these fields are returned by zendesk service
  let(:new_requester_id) { nil }
  let(:new_ticket_id) { nil }

  describe "#perform" do
    context "without errors" do
      let(:fake_ticket) { double(ZendeskAPI::Ticket, id: new_ticket_id) }

      before do
        allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
        allow(fake_zendesk_intake_service).to receive(:assign_requester).and_return(new_requester_id)
        allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(fake_ticket)
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

        context "creates a new client effort" do
          it "creates a client effort with effort_type consented" do
            expect{
              described_class.perform_now(intake.id)
            }.to change(ClientEffort, :count).by(1)

            client_effort = ClientEffort.last
            expect(client_effort.effort_type_consented?).to eq true
            expect(client_effort.intake).to eq intake
            expect(client_effort.ticket_id).to eq new_ticket_id
            expect(client_effort.made_at).to be_within(1.second).of(Time.now)
          end
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

        context "when client has a diy intake ticket" do
          let(:diy_ticket_id) { 12 }
          let(:new_ticket_id) { 33 }
          let!(:diy_intake) { create :diy_intake, email_address: "filer@example.horse", ticket_id: diy_ticket_id }

          before do
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
      end

      context "with a requester and ticket" do
        let(:intake_requester_id) { 32 }
        let(:intake_ticket_id) { 7 }

        it "does not call the zendesk service" do
          described_class.perform_now(intake.id)

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
      end

      it "does not try to create a ticket" do
        described_class.perform_now(intake.id)

        expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
      end
    end
  end
end
