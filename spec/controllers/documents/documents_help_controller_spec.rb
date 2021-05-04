require "rails_helper"

RSpec.describe Documents::DocumentsHelpController, type: :controller do
  describe "#show" do
    let!(:client) { create :client, intake: create(:intake) }
    let(:next_path) { "/en/next" }
    let(:params) do
      {
          doc_type: "DocumentTypes::Identity",
          next_path: next_path
      }
    end

    before do
      sign_in client
    end

    context "without a next_path param provided" do
      let(:next_path) { nil }
      it "redirects" do
        get :show, params: params
        expect(response).to redirect_to "/en/portal"
      end
    end

    it "renders show template" do
      get :show, params: params
      expect(response).to render_template :show
    end

    it "does not set current step on the intake" do
      get :show, params: params
      expect(client.intake.reload.current_step).to eq nil
    end
  end

  describe "#send_reminder" do
    let!(:client) { create(:intake, email_address: "gork@example.com", sms_phone_number: "+14155537865", email_notification_opt_in: "yes", sms_notification_opt_in: "yes", preferred_name: "Gilly").client }
    let(:params) do
      { next_path: "/en/documents/selfies",
        doc_type: "DocumentTypes::Identity" }
    end

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      sign_in client
    end

    it "sends a message with the reminder link in the preferred contact method" do
      post :send_reminder, params: params

      sms_body = <<~SMS
        Hello Gilly,
        We received your request for a reminder. Please login here to upload ID documents: http://test.host/en/portal/login
        Your tax team at GetYourRefund
      SMS

      email_body = <<~EMAIL
        Hello Gilly,
        We received your request for a reminder. Please <a href=\"http://test.host/en/portal/login\">login here</a> to upload ID documents.
        Your tax team at GetYourRefund
      EMAIL

      expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
        client,
        email_body: email_body,
        sms_body: sms_body,
        subject: "Your tax document reminder"
      )
    end

    it "redirects to next path and flashes an notice" do
      post :send_reminder, params: params
      expect(response).to redirect_to("/en/documents/selfies")
      expect(flash.now[:notice]).to eq "Great! We just sent you a reminder link."
    end
  end

  describe "#request_doc_help" do
    let!(:client) { create :client, intake: create(:intake) }

    before do
      sign_in client
      allow_any_instance_of(Client).to receive(:request_document_help)
    end

    context "client needs help finding document" do
      let(:help_type){ }
      let(:params) do
        { next_path: "/en/documents/selfies",
          doc_type: "DocumentTypes::Identity",
          help_type: help_type
        }
      end
      context "for each valid help type" do
        DocumentTypes::HELP_TYPES.each do |help_type_sym|
          let(:help_type) { help_type_sym.to_s }
          context "#{help_type_sym}" do
            it "flashes a notice and redirects to next path" do
              post :request_doc_help, params: params
              expect(response).to redirect_to("/en/documents/selfies")
              expect(flash.now[:notice]).to eq "Thank you! We updated your tax specialist."
            end

            it "calls client request_doc_help" do
              post :request_doc_help, params: params
              expect(assigns(:current_client)).to have_received(:request_document_help).with(doc_type: DocumentTypes::Identity, help_type: help_type)
            end
          end
        end
      end
    end

    context "not valid help type" do
      let(:invalid_params) do
        { next_path: "/en/documents/selfies",
          doc_type: "DocumentTypes::Identity",
          help_type: "garbage"
        }
      end

      it "raises an error" do
        expect do
          post :request_doc_help, params: invalid_params
        end.to raise_error(ArgumentError)
      end
    end
  end
end