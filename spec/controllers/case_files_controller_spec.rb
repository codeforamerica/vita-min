require "rails_helper"

RSpec.describe CaseFilesController do
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
          }.not_to change(CaseFile, :count)

          expect(response.status).to eq 422
        end
      end

      context "with an intake id" do
        it "creates a case_file from the intake and redirects to show" do
          expect {
            post :create, params: valid_params
          }.to change(CaseFile, :count).by(1)

          new_case = CaseFile.last
          expect(new_case.email_address).to eq "client@example.com"
          expect(new_case.phone_number).to eq "14155537865"
          expect(new_case.preferred_name).to eq "Casey"
          expect(response).to redirect_to case_file_path(id: new_case.id)
        end
      end
    end
  end

  describe "#show" do
    before do
      allow(subject).to receive(:current_user).and_return user
    end

    let(:client_case) { create :case_file }

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        get :show, params: { id: client_case.id }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        get :show, params: { id: client_case.id }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      render_views

      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      it "shows case_file information" do
        get :show, params: { id: client_case.id }

        expect(response.body).to include(client_case.preferred_name)
        expect(response.body).to include(client_case.email_address)
        expect(response.body).to include(client_case.phone_number)
      end

      context "with existing contact history" do
        let!(:expected_contact_history) do
          [
            create(:outgoing_text_message, body: "Your tax return is great", sent_at: DateTime.new(2020, 1, 1, 0, 0, 1), case_file: client_case, twilio_status: twilio_status),
          ]
        end

        context "with a status from Twilio" do
          let(:twilio_status) { "queued" }

          it "displays prior messages" do
            get :show, params: { id: client_case.id }

            expect(assigns(:contact_history)).to eq expected_contact_history
            expect(response.body).to include("Your tax return is great")
            expect(response.body).to include("queued")
          end
        end

        context "without a status from Twilio" do
          let(:twilio_status) { nil }

          it "shows sending... for outgoing text messages without a Twilio status" do
            get :show, params: { id: client_case.id }

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

    let(:client_case) { create :case_file }

    context "as an anonymous user" do
      let(:user) { nil }
      it "redirects to sign in" do
        post :send_text, params: { case_file_id: client_case.id, body: "This is an outgoing text" }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated non-admin user" do
      let(:user) { build :user, provider: "zendesk", id: 1 }

      it "redirects to sign in" do
        post :send_text, params: { case_file_id: client_case.id, body: "This is an outgoing text" }

        expect(response).to redirect_to zendesk_sign_in_path
      end
    end

    context "as an authenticated admin user" do
      render_views

      let(:user) { build :user, provider: "zendesk", id: 1, role: "admin" }

      it "sends a text" do
        expect {
          post :send_text, params: { case_file_id: client_case.id, body: "This is an outgoing text" }
        }.to change(OutgoingTextMessage, :count).from(0).to(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq "This is an outgoing text"
        expect(outgoing_text_message.case_file).to eq client_case
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
        expect(response).to redirect_to(case_file_path(id: client_case.id))
      end
    end
  end

  describe "#text_status_callback" do
    let(:outgoing_text_message) { create :outgoing_text_message }

    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:secret_key_base).and_return("a_secret_key")
    end

    context "with invalid params" do
      it "does nothing" do
        expect {
          post :text_status_callback, params: { verifiable_outgoing_text_message_id: "bad_id", message_status: "fake_status" }
        }.not_to change { outgoing_text_message.twilio_status }
      end
    end

    context "with valid params" do
      it "saves the status to the message" do
        verifiable_id = ActiveSupport::MessageVerifier.new("a_secret_key").generate(
          outgoing_text_message.id.to_s, purpose: :twilio_text_message_status_callback
        )
        post :text_status_callback, params: {
          verifiable_outgoing_text_message_id: verifiable_id,
          MessageStatus: "sent"
        }

        expect(outgoing_text_message.reload.twilio_status).to eq "sent"
      end
    end
  end

  describe "#incoming_text_message" do
    let(:fake_validator) { instance_double(Twilio::Security::RequestValidator) }
    let(:incoming_phone_number) { "+15555551212" }

    before do
      allow(Twilio::Security::RequestValidator).to receive(:new).and_return fake_validator
    end

    context "the request passes Twilio's request validation" do
      before do
        allow(fake_validator).to receive(:validate).and_return true
      end

      context "one case file matches the incoming phone number" do
        let!(:case_file) { create(:case_file, sms_phone_number: incoming_phone_number) }

        it "creates an IncomingTextMessage tied to the case file" do
          expect {
            post :incoming_text_message, params: { from: incoming_phone_number, body: "sup cfa" }
          }.to change(IncomingTextMessage, :count).from(0).to(1)
          message = IncomingTextMessage.last
          expect(message.body).to eq("sup cfa")
          expect(message.case_file).to eq(case_file)
        end
      end

      context "multiple case files match the incoming phone number" do
        let!(:case_file_1) { create(:case_file, sms_phone_number: incoming_phone_number) }
        let!(:case_file_2) { create(:case_file, sms_phone_number: incoming_phone_number) }

        it "creates an IncomingTextMessage tied to any matching case file" do
          expect {
            post :incoming_text_message, params: { from: incoming_phone_number, body: "sup cfa" }
          }.to change(IncomingTextMessage, :count).from(0).to(1)
          message = IncomingTextMessage.last
          expect(message.body).to eq("sup cfa")
          expect(message.case_file).to eq(case_file_1) | eq(case_file_2)
        end
      end

      context "no case file matches the incoming phone number" do
        it "does nothing" do
          expect {
            post :incoming_text_message, params: { from: incoming_phone_number, body: "sup cfa" }
          }.not_to change(IncomingTextMessage, :count)
        end
      end
    end

    context "the request fails Twilio's request validation" do
      before do
        create(:case_file, sms_phone_number: incoming_phone_number)
        allow(fake_validator).to receive(:validate).and_return false
      end

      it "does not create an IncomingTextMessage and provides a 403 status code" do
        expect {
          post :incoming_text_message, params: { from: incoming_phone_number, body: "sup cfa" }
        }.not_to change(IncomingTextMessage, :count)

        expect(response.status).to eq 403
      end
    end
  end
end
