require "rails_helper"

RSpec.describe ZendeskNotificationOptInBackfill do
  describe '.update_zendesk_tickets' do
    let(:fake_zendesk_ticket) { double(ZendeskAPI::Ticket, id: 123) }
    let(:user_properties) { {} }
    let!(:user) { create(:user, intake: intakes[0], **user_properties) }
    let!(:intakes) do
      [
        create(:intake, intake_ticket_id: fake_zendesk_ticket.id),
      ]
    end

    before do
      allow(fake_zendesk_ticket).to receive(:save)
      allow(fake_zendesk_ticket).to receive(:fields=)
      allow_any_instance_of(ZendeskIntakeService)
        .to receive(:get_ticket)
        .with(ticket_id: fake_zendesk_ticket.id)
        .and_return(fake_zendesk_ticket)
    end

    describe "for an intake with communication preferences" do
      let(:user_properties) do
        {
          sms_notification_opt_in: "yes",
          email_notification_opt_in: "yes"
        }
      end

      it "backfills the fields as we expect" do
        described_class.update_zendesk_tickets
        expect(fake_zendesk_ticket).to have_received(:save)
        expect(fake_zendesk_ticket).to have_received(:fields=)
          .with(EitcZendeskInstance::COMMUNICATION_PREFERENCES => ["sms_opt_in", "email_opt_in"])
      end
    end

    describe "for an intake with no communication preferences" do
      let(:user_properties) { {} }

      it "backfills the fields as we expect" do
        described_class.update_zendesk_tickets
        expect(fake_zendesk_ticket).to have_received(:save)
        expect(fake_zendesk_ticket).to have_received(:fields=)
          .with(EitcZendeskInstance::COMMUNICATION_PREFERENCES => [])
      end
    end

    describe "for an intake with no zendesk ticket" do
      let!(:intakes) { [create(:intake, intake_ticket_id: nil)] }

      it "does not crash" do
        expect do
          described_class.update_zendesk_tickets
        end.not_to raise_error
      end
    end
  end
end
