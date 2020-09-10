require "rails_helper"

RSpec.describe OutgoingTextMessagesController do
  describe "#create" do
    before do
      allow(subject).to receive(:current_user).and_return user
    end

    let(:client) { create :client }
    let(:valid_params) do
      {
        outgoing_text_message: {
          client_id: client.id,
          body: "This is an outgoing text"
        }
      }
    end

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to client page" do
        post :create, params: valid_params

        expect(response).to redirect_to client_path(id: client.id)
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to client page" do
        post :create, params: valid_params

        expect(response).to redirect_to client_path(id: client.id)
      end
    end

    context "as an authenticated admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      it "sends a text", active_job: true do
        expect {
          post :create, params: valid_params
        }.to change(OutgoingTextMessage, :count).from(0).to(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq "This is an outgoing text"
        expect(outgoing_text_message.client).to eq client
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
        expect(response).to redirect_to(client_path(id: client.id))
      end
    end
  end
end
