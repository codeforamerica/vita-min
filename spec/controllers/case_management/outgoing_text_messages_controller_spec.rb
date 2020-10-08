require "rails_helper"

RSpec.describe CaseManagement::OutgoingTextMessagesController do
  describe "#create" do
    let(:client) { create :client, sms_phone_number: "+15105551234", phone_number: "+15105551777" }
    let(:params) do
      {
        client_id: client.id,
        outgoing_text_message: {
          body: "This is an outgoing text"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

    context "as an authenticated beta user" do
      let(:beta_user) { create :beta_tester }
      before { sign_in beta_user }

      it "sends a text", active_job: true do
        expect {
          post :create, params: params
        }.to change(OutgoingTextMessage, :count).from(0).to(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq "This is an outgoing text"
        expect(outgoing_text_message.to_phone_number).to eq client.sms_phone_number
        expect(outgoing_text_message.client).to eq client
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
        expect(response).to redirect_to(case_management_client_messages_path(client_id: client.id))
      end
    end
  end
end
