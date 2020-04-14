require "rails_helper"

RSpec.describe ZendeskPhoneNumberBackfill do
  describe '.update_zendesk!' do
    let(:fake_zendesk_user) do
      double(ZendeskAPI::User, id: 1234569879, phone: "5105551234", email: "testy@example.com", name: "Testy McTestuser")
    end
    let(:user_properties) { {} }
    let(:intake_properties) { {} }
    let!(:user) { create(:user, intake: intakes[0], **user_properties) }
    let!(:intakes) do
      [
        create(:intake, **intake_properties),
      ]
    end

    before do
      allow(fake_zendesk_user).to receive(:save)
      allow(fake_zendesk_user).to receive(:phone=)
      allow_any_instance_of(ZendeskIntakeService)
        .to receive(:get_end_user)
        .with(user_id: fake_zendesk_user.id)
        .and_return(fake_zendesk_user)
      allow_any_instance_of(ZendeskDropOffService)
        .to receive(:get_end_user)
        .with(user_id: fake_zendesk_user.id)
        .and_return(fake_zendesk_user)
      allow_any_instance_of(ZendeskDropOffService)
        .to receive(:find_end_user)
        .with(fake_zendesk_user.name, fake_zendesk_user.email, include(fake_zendesk_user.phone))
        .and_return(fake_zendesk_user.id)
    end

    describe "for an intake with a non-E164 phone number" do
      let(:intake_properties) do
        {
          intake_ticket_requester_id: fake_zendesk_user.id,
        }
      end

      let(:user_properties) do
        {
          phone_number: "5105551234"
        }
      end

      it "backfills the fields as we expect" do
        described_class.update_zendesk!
        expect(fake_zendesk_user).to have_received(:save)
        expect(fake_zendesk_user).to have_received(:phone=)
          .with("+15105551234")
      end
    end

    describe "for a drop-off" do
      let!(:drop_off) do
        create(:intake_site_drop_off,
               name: fake_zendesk_user.name,
               phone_number: fake_zendesk_user.phone,
               email: fake_zendesk_user.email
              )
      end

      it "backfills the fields as we expect" do
        described_class.update_zendesk!
        expect(fake_zendesk_user).to have_received(:save)
        expect(fake_zendesk_user).to have_received(:phone=)
          .with("+15105551234")
      end
    end
  end
end
