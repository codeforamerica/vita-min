require "rails_helper"

RSpec.describe BackfillLastOutgoingInteractionAt, type: :job do
  describe '#perform' do
    let!(:client1) { create(:client) }
    let!(:client2) { create(:client) }
    let!(:client3) { create(:client) }

    let!(:text) { create(:outgoing_text_message, created_at: Time.now - 1.day, client: client1) }
    let!(:text2) { create(:outgoing_text_message, created_at: Time.now, client: client1) }
    let!(:text3) { create(:outgoing_text_message, created_at: Time.now - 1.day, client: client2) }
    let!(:email) { create(:outgoing_email, created_at: Time.now, client: client2) }
    let!(:call) { create(:outbound_call, client: client3) }

    context "when a client has no last_outgoing_interaction_at" do
      before do
        # have to set these due to after_create hooks
        client1.update(last_outgoing_interaction_at: nil)
        client2.update(last_outgoing_interaction_at: nil)
        client3.update(last_outgoing_interaction_at: nil)
      end

      it "sets the last_outgoing_interaction_at to the last interactions created_at" do
        expect do
          subject.perform_now
          client1.reload
          client2.reload
          client3.reload
        end
          .to change(client1, :last_outgoing_interaction_at).from(nil).to(text2.created_at)
          .and change(client2, :last_outgoing_interaction_at).from(nil).to(email.created_at)
          .and change(client3, :last_outgoing_interaction_at).from(nil).to(call.created_at)
      end
    end

    context "when the client has last_outgoing_interaction_at set" do
      it "does not set it" do
        expect { subject.perform }.not_to change(client1, :last_outgoing_interaction_at)
      end
    end
  end
end