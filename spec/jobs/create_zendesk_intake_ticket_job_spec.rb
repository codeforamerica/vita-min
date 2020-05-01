require 'rails_helper'

RSpec.describe CreateZendeskIntakeTicketJob, type: :job do
  let(:zendesk_requester_id) { nil }
  let(:zendesk_ticket_id) { nil }
  let(:intake) { create :intake, intake_ticket_id: zendesk_ticket_id, intake_ticket_requester_id: zendesk_requester_id }
  let(:fake_zendesk_intake_service) { double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
    allow(fake_zendesk_intake_service).to receive(:create_intake_ticket_requester).and_return(23)
    allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(5)
  end


  describe '#perform unexpectedly' do
    context 'when unable to create a ticket requester' do
      before do
        allow(fake_zendesk_intake_service).to receive(:create_intake_ticket_requester) { nil }
      end
      it 'notifies sentry' do
        user_attributes = {
            name: intake.preferred_name,
            email: intake.email_address,
            phone: intake.phone_number
        }
        expect(Raven).to receive(:capture_message)
                             .with('ZendeskIntakeTicketJob failed to create a ticket requester',
                                   {
                                       extra: user_attributes,
                                       severity: Severity::ERROR
                                   })

        described_class.perform_now(intake.id)
      end

      it 'does not create a ticket' do
        expect(fake_zendesk_intake_service).to_not receive(:create_intake_ticket)
        described_class.perform_now(intake.id)
      end

    end

    context 'when unable to create a ticket' do
      before do
        allow(fake_zendesk_intake_service).to receive(:create_intake_ticket) { nil }
      end
      it 'notifies sentry' do
        user_attributes = {
            name: intake.preferred_name,
            email: intake.email_address,
            phone: intake.phone_number
        }
        expect(Raven).to receive(:capture_message)
                             .with('ZendeskIntakeTicketJob failed to create an intake ticket',
                                   {
                                       extra: user_attributes,
                                       severity: Severity::ERROR
                                   })

        described_class.perform_now(intake.id)
      end
    end
  end

  describe "#perform" do
    context "without errors" do
      before do
        described_class.perform_now(intake.id)
      end

      context "without a requester or ticket" do
        let(:zendesk_requester_id) { nil }
        let(:zendesk_ticket_id) { nil }

        it "creates a new intake ticket in Zendesk and saves IDs to the intake" do
          intake.reload
          expect(ZendeskIntakeService).to have_received(:new).with(intake)
          expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket_requester).with(no_args)
          expect(intake.intake_ticket_requester_id).to eq 23
          expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
          expect(intake.intake_ticket_id).to eq 5
        end

      end

      context "with a requester but no ticket" do
        let(:zendesk_requester_id) { 32 }
        let(:zendesk_ticket_id) { nil }

        it "only creates a ticket" do
          intake.reload
          expect(ZendeskIntakeService).to have_received(:new).with(intake)
          expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket_requester)
          expect(intake.intake_ticket_requester_id).to eq 32
          expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
          expect(intake.intake_ticket_id).to eq 5
        end
      end

      context "with a requester and ticket" do
        let(:zendesk_requester_id) { 32 }
        let(:zendesk_ticket_id) { 7 }

        it "does not call the zendesk service" do
          intake.reload
          expect(ZendeskIntakeService).not_to have_received(:new)
          expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket_requester)
          expect(intake.intake_ticket_requester_id).to eq 32
          expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
          expect(intake.intake_ticket_id).to eq 7
        end
      end
    end

    it_behaves_like "catches exceptions with raven context", :create_intake_ticket
  end
end
