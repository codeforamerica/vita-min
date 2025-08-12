require "rails_helper"

RSpec.describe ClientInteractionNotificationEmailJob, type: :job do
  describe "#perform" do
    let(:internal_email) { create :internal_email }
    let(:mailer) { double(UserMailer) }
    let(:message_id) { "some_fake_id" }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }
    let(:client) { create(:client, first_unanswered_incoming_interaction_at: fake_time) }
    let(:user) { create :user }
    let!(:interaction) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time) }

    before do
      allow(UserMailer).to receive(:assignment_email).and_return(mailer)
      allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
    end

    context "when hub_email_notifications flipper flag is enabled and last client message is unanswered" do
      before do
        allow(Flipper).to receive(:enabled?).with(:hub_email_notifications).and_return(true)
      end

      context "one interaction within 10 minutes" do
        it "sends the message using deliver_now and persists the message_id & sent_at" do
          Timecop.freeze(fake_time) do
            described_class.perform_now(interaction, user)
          end
          expect(UserMailer).to have_received(:assignment_email).with(internal_email.deserialized_mail_args)
          expect(internal_email.reload.outgoing_message_status.message_id).to eq message_id
        end

        it "deletes the client interaction" do
          expect do
            described_class.perform_now(interaction, user)
          end.to change(ClientInteraction, :count).by -1
        end
      end

      context "when not the most recent interaction within 10 minutes" do
        let!(:interaction_2) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time + 3.minutes) }
        let!(:interaction_3) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time + 5.minutes) }

        it "doesn't send the message and doesn't delete any ClientInteractions" do
          expect do
            described_class.perform_now(interaction, user)
          end.to change(ClientInteraction, :count).by 0

          expect(UserMailer).not_to have_received(:assignment_email)
        end
      end

      context "2 interactions within 10 minutes and 1 interaction after the interaction window" do
        let!(:interaction_2) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time + 3.minutes) }
        let!(:interaction_3) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time + 11.minutes) }

        it "sends the messsage for first window and deletes their interactions and not the second window" do
          expect do
            described_class.perform_now(internal_email, interaction_2)
          end.to change(ClientInteraction, :count).by -2
          expect(UserMailer).to have_received(:assignment_email)

          expect(ClientInteraction.find_by(id: interaction.id)).to be_nil
          expect(ClientInteraction.find_by(id: interaction_2.id)).to be_nil
          expect(ClientInteraction.find_by(id: interaction_3.id)).to be_present
        end
      end

      context "when earliest interaction is more than 10 minutes before the interaction passed to the job" do
        let!(:older_interaction) { create(:client_interaction, client: client, interaction_type: "client_message", created_at: fake_time - 15.minutes) }

        it "sends the messsage for this interaction and deletes the interaction but not the older interaction" do
          expect do
            described_class.perform_now(interaction, user)
          end.to change(ClientInteraction, :count).by -1
          expect(UserMailer).to have_received(:assignment_email)

          expect(ClientInteraction.find_by(id: interaction.id)).to be_nil
          expect(ClientInteraction.find_by(id: older_interaction.id)).to be_present
        end
      end
    end

    context "when hub_email_notifications flipper flag is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:hub_email_notifications).and_return(false)
      end

      it "doesn't sends the message" do
        Timecop.freeze(fake_time) do
          described_class.perform_now(interaction, user)
        end
        expect(UserMailer).not_to have_received(:assignment_email)
      end

      it "doesn't deletes the client interaction" do
        expect do
          described_class.perform_now(interaction, user)
        end.to change(ClientInteraction, :count).by 0
      end
    end

    context "when last client message has been responded to by a user" do
      before do
        client.update!(first_unanswered_incoming_interaction_at: nil)
      end

      it "doesn't sends the message" do
        Timecop.freeze(fake_time) do
          described_class.perform_now(interaction, user)
        end
        expect(UserMailer).not_to have_received(:assignment_email)
      end

      it "doesn't deletes the client interaction" do
        expect do
          described_class.perform_now(interaction, user)
        end.to change(ClientInteraction, :count).by 0
      end
    end
  end
end
