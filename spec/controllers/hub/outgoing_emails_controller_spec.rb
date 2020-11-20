require "rails_helper"

RSpec.describe Hub::OutgoingEmailsController do
  describe "#create" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let!(:intake) { create :intake, client: client, email_address: "loose.seal@example.com" }
    let(:params) do
      { client_id: client.id, outgoing_email: { body: "hi client" } }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated admin user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before do
        sign_in user
        allow(subject).to receive(:send_email)
      end

      context "with body & client_id" do
        let(:params) do
          {
            client_id: client.id,
            outgoing_email: {
              body: "hi client",
              attachment: fixture_file_upload("attachments/test-pattern.png")
            }
          }
        end

        it "calls the send_email method with the right arguments and redirects to messages page" do
          post :create, params: params

          expect(subject).to have_received(:send_email).with("hi client", attachment: instance_of(ActionDispatch::Http::UploadedFile))
          expect(response).to redirect_to hub_client_messages_path(client_id: client.id)
        end
      end

      context "without body" do
        let(:params) do
          { client_id: client.id, outgoing_email: { body: " " } }
        end

        it "doesn't call send_email but still redirects to messages" do
          post :create, params: params

          expect(subject).not_to have_received(:send_email)
          expect(response).to redirect_to hub_client_messages_path(client_id: client.id)
        end
      end
    end
  end
end
