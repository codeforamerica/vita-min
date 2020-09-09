require "rails_helper"

RSpec.describe ClientsController do
  describe "#create" do
    let(:intake) { create :intake, email_address: "client@example.com", phone_number: "14155537865", preferred_name: "Casey" }
    let(:valid_params) do
      { intake_id: intake.id }
    end

    before do
      allow(subject).to receive(:current_user).and_return user
    end

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        post :create, params: valid_params

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        post :create, params: valid_params

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      context "without an intake id" do
        it "does nothing and returns invalid request status code" do
          expect {
            post :create, params: {}
          }.not_to change(Client, :count)

          expect(response.status).to eq 422
        end
      end

      context "with an intake id" do
        it "creates a client from the intake and redirects to show" do
          expect {
            post :create, params: valid_params
          }.to change(Client, :count).by(1)

          client = Client.last
          expect(client.email_address).to eq "client@example.com"
          expect(client.phone_number).to eq "14155537865"
          expect(client.preferred_name).to eq "Casey"
          expect(response).to redirect_to client_path(id: client.id)
        end
      end
    end
  end

  describe "#show" do
    before do
      allow(subject).to receive(:current_user).and_return user
    end

    let(:client) { create :client }

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        get :show, params: { id: client.id }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        get :show, params: { id: client.id }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      render_views

      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      it "shows client information" do
        get :show, params: { id: client.id }

        expect(response.body).to include(client.preferred_name)
        expect(response.body).to include(client.email_address)
        expect(response.body).to include(client.phone_number)
      end

      context "with existing contact history" do
        let!(:expected_contact_history) do
          [
            create(:outgoing_text_message, body: "Your tax return is great", sent_at: DateTime.new(2020, 1, 1, 0, 0, 1), client: client, twilio_status: twilio_status),
            create(:incoming_text_message, body: "Thx appreciate yr gratitude", received_at: DateTime.new(2020, 1, 1, 0, 0, 2), client: client),
          ]
        end

        context "with a status from Twilio" do
          let(:twilio_status) { "queued" }

          it "displays prior messages" do
            get :show, params: { id: client.id }

            expect(assigns(:contact_history)).to eq expected_contact_history
            expect(response.body).to include("Your tax return is great")
            expect(response.body).to include("queued")
            expect(response.body).to include("Thx appreciate yr gratitude")
          end
        end

        context "without a status from Twilio" do
          let(:twilio_status) { nil }

          it "shows sending... for outgoing text messages without a Twilio status" do
            get :show, params: { id: client.id }

            expect(response.body).to include("sending...")
          end
        end
      end
    end
  end

  describe "#send_text" do
    before do
      allow(subject).to receive(:current_user).and_return user
    end

    let(:client) { create :client }

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        post :send_text, params: { client_id: client.id, body: "This is an outgoing text" }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        post :send_text, params: { client_id: client.id, body: "This is an outgoing text" }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      render_views

      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      it "sends a text", active_job: true do
        expect {
          post :send_text, params: { client_id: client.id, body: "This is an outgoing text" }
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
