require "rails_helper"

RSpec.describe Documents::DocumentsHelpController, type: :controller do
  describe "#show" do
    let!(:client) { create :client, intake: create(:intake) }
    let(:next_path) { "/en/next" }
    let(:params) do
      {
          doc_type: "id",
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
        doc_type: "id" }
    end

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      sign_in client
    end

    it "sends a message with the reminder link in the preferred contact method" do
      post :send_reminder, params: params

      expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
        client: client,
        email_body: I18n.t("documents.reminder_link.email_body", doc_type: "ID"),
        sms_body: I18n.t("documents.reminder_link.sms_body", doc_type: "ID"),
        subject: "Your tax document reminder",
        locale: :en
      )
    end

    context "when locale is spanish" do
      it "uses the spanish translation" do
        post :send_reminder, params: params.merge(locale: "es")

        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: client,
          email_body: I18n.t("documents.reminder_link.email_body", doc_type: "ID", locale: "es"),
          sms_body: I18n.t("documents.reminder_link.sms_body", doc_type: "ID", locale: "es"),
          subject: I18n.t("documents.reminder_link.subject", locale: "es"),
          locale: :es
        )
      end
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
          doc_type: "employment",
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
              expect(assigns(:current_client)).to have_received(:request_document_help).with(doc_type: DocumentTypes::Employment, help_type: help_type)
            end
          end
        end
      end
    end

    context "not valid help type" do
      let(:invalid_params) do
        { next_path: "/en/documents/selfies",
          doc_type: "1099-g",
          help_type: "garbage"
        }
      end

      it "raises an error" do
        expect do
          post :request_doc_help, params: invalid_params
        end.to raise_error(ArgumentError)
      end
    end

    context "doc_type param" do
      context "with valid doc_type param" do
        let(:params) do
          {
            next_path: "/en/documents/selfies",
            doc_type: "id",
            help_type: "doesnt_apply"
          }
        end

        it "is successful" do
          post :request_doc_help, params: params
          expect(response).to redirect_to params[:next_path]
        end
      end

      context "with temporary, legacy class doc type" do
        let(:params) do
          {
              next_path: "/en/documents/selfies",
              doc_type: "DocumentTypes::Identity",
              help_type: "doesnt_apply"
          }
        end

        it "is successful" do
          post :request_doc_help, params: params
          expect(response).to redirect_to params[:next_path]
        end
      end

      context "with invalid doc type" do
        let(:params) do
          {
            next_path: "/en/documents/selfies",
            doc_type: "something",
            help_type: "doesnt_apply"
          }
        end

        it "raises an error" do
          expect {
            post :request_doc_help, params: params
          }.to raise_error ArgumentError
        end
      end
    end
  end
end