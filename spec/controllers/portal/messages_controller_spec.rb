require "rails_helper"

describe Portal::MessagesController do
  let(:client) { create :client, intake: (create :intake, email_address: "exampleton@example.com", email_notification_opt_in: "yes") }
  before do
    sign_in client, scope: :client
  end

  describe "#new" do
    it "renders the new template and initializes a portal message object" do
      get :new
      expect(response).to render_template :new
      expect(assigns(:message)).to be_an_instance_of IncomingPortalMessage
      expect(assigns(:message).client).to eq client
    end
  end

  describe "#create" do
    context "with valid params" do
      let(:params) do
        {
          incoming_portal_message: {
            body: "I have some urgent questions!!"
          }
        }
      end

      it "creates a message and redirects to portal home with flash" do
        expect {
          post :create, params: params
        }.to change(client.incoming_portal_messages, :count).by 1

        expect(response).to redirect_to portal_root_path
        expect(flash[:notice]).to eq "Message sent! Responses will be sent by email to exampleton@example.com."
      end
    end

    context "with invalid params" do
      let(:params) do
        {
            incoming_portal_message: {
                body: ""
            }
        }
      end

      it "renders the new page with errors" do
        post :create, params: params
        expect(response).to render_template :new
        expect(assigns[:message].errors).to include :body
        expect(flash[:alert]).to eq "Please fix indicated errors and try again."
      end
    end
  end
end