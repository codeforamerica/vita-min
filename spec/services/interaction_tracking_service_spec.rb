require 'rails_helper'

describe InteractionTrackingService do
  let(:client) { create(:client) }
  let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

  describe ".update_last_outgoing_communication_at" do
    it "updates Client.last_outgoing_communication_at" do
      Timecop.freeze(fake_time) do
        expect { described_class.update_last_outgoing_communication_at(client) }.to change { client.last_outgoing_communication_at }.from(nil).to(fake_time)
      end
    end
  end

  describe "#record_incoming_interaction" do
    let!(:tax_return_1) { create(:tax_return, assigned_user_id: user.id, year: Rails.configuration.product_year, client: client) }
    let!(:tax_return_2) { create(:tax_return, assigned_user_id: user_no_notifications.id, year: (Rails.configuration.product_year - 1), client: client) }
    let(:user) { create(:admin_user, email_notification: "yes") }
    let(:user_no_notifications) { create(:admin_user, email_notification: "no") }

    before do
      allow(Flipper).to receive(:enabled?).with(:hub_email_notifications).and_return(true)
      allow(InternalEmail).to receive(:create!).and_call_original
      allow(SendInternalEmailJob).to receive(:perform_later)
    end

    it "sends a notification and enqueues the email job" do
      described_class.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
      expect(InternalEmail).to have_received(:create!).with(
        mail_class: UserMailer,
        mail_method: :incoming_interaction_notification_email,
        mail_args: ActiveJob::Arguments.serialize(
          client: client,
          user: user,
          interaction_type: :client_message
        )
      )
      expect(SendInternalEmailJob).to have_received(:perform_later)
    end

    it "doesn't send a message for the user that has chosen to opt-out of email notifications" do
      described_class.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
      expect(InternalEmail).not_to have_received(:create!).with(
        mail_class: UserMailer,
        mail_method: :incoming_interaction_notification_email,
        mail_args: ActiveJob::Arguments.serialize(
          client: client,
          user: user_no_notifications,
          interaction_type: :client_message
        )
      )
    end

    context "when the interaction type is not client_message" do
      it "doesn't send any email notifications" do
        described_class.record_incoming_interaction(client, set_flag: true, interaction_type: nil)
        expect(InternalEmail).not_to have_received(:create!)
        expect(SendInternalEmailJob).not_to have_received(:perform_later)
      end
    end

    context "when the client doesn't have any assigned users" do
      before do
        tax_return_1.update!(assigned_user: nil)
        tax_return_2.update!(assigned_user: nil)
      end
      it "doesn't send any email notifications" do
        described_class.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
        expect(InternalEmail).not_to have_received(:create!)
        expect(SendInternalEmailJob).not_to have_received(:perform_later)
      end
    end

    context "when only one tax return has an assigned user" do
      before do
        tax_return_2.update!(assigned_user: nil)
      end
      it "only sends email notification that user" do
        described_class.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
        expect(InternalEmail).to have_received(:create!).with(
          mail_class: UserMailer,
          mail_method: :incoming_interaction_notification_email,
          mail_args: ActiveJob::Arguments.serialize(
            client: client,
            user: user,
            interaction_type: :client_message
          )
        )
        expect(SendInternalEmailJob).to have_received(:perform_later)
      end
    end

    context "when the flipper flag 'hub_email_notifications' is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:hub_email_notifications).and_return(false)
      end

      it "doesn't send any email notifications" do
        described_class.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
        expect(InternalEmail).not_to have_received(:create!)
        expect(SendInternalEmailJob).not_to have_received(:perform_later)
      end
    end

    context "when first_unanswered_incoming_interaction_at is nil and set_flag is true" do
      let(:client) { create(:client, first_unanswered_incoming_interaction_at: nil, flagged_at: nil, last_incoming_interaction_at: 2.days.ago) }

      it "touches last_incoming_interaction_at, first_unanswered_incoming_interaction_at, and flagged_at" do
        Timecop.freeze(fake_time) do
          InteractionTrackingService.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
          client.reload

          expect(client.last_incoming_interaction_at).to eq fake_time
          expect(client.first_unanswered_incoming_interaction_at).to eq fake_time
          expect(client.flagged_at).to eq fake_time
        end
      end
    end

    context "when first_unanswered_incoming_interaction_at is already present" do
      let(:existing_time) { fake_time - 3.days }
      let(:client) { create(:client, first_unanswered_incoming_interaction_at: existing_time, flagged_at: nil, last_incoming_interaction_at: fake_time - 4.days) }

      it "only touches last_incoming_interaction_at and flagged_at" do
        Timecop.freeze(fake_time) do
          InteractionTrackingService.record_incoming_interaction(client, set_flag: true, interaction_type: :client_message)
          client.reload

          expect(client.last_incoming_interaction_at).to eq fake_time
          expect(client.first_unanswered_incoming_interaction_at).to eq existing_time
          expect(client.flagged_at).to eq fake_time
        end
      end
    end

    context "when set_flag is false" do
      let(:client) { create(:client, first_unanswered_incoming_interaction_at: nil, flagged_at: nil, last_incoming_interaction_at: fake_time - 5.days) }

      it "touches only last_incoming_interaction_at and first_unanswered_incoming_interaction_at, but leaves flagged_at nil" do
        Timecop.freeze(fake_time) do
          InteractionTrackingService.record_incoming_interaction(client, set_flag: false, interaction_type: :sms)
          client.reload

          expect(client.last_incoming_interaction_at).to eq fake_time
          expect(client.first_unanswered_incoming_interaction_at).to eq fake_time
          expect(client.flagged_at).to be_nil
        end
      end
    end
  end
end
