require "rails_helper"

RSpec.describe Documents::RequestedDocumentsLaterController, type: :controller do
  render_views
  let(:token) {"t0k3nN0tbr0k3n?"}
  let!(:original_intake) { create :intake, requested_docs_token: token, intake_ticket_id: 123 }
  let!(:anonymous_intake) { create :anonymous_intake, intake_ticket_id: 123 }

  describe "#edit" do
    context "with no session" do
      context "with no intake matching the token" do
        it "redirects to an error page" do
          get :edit, params: {token: "br0k3nt0k3n"}

          expect(response).to redirect_to documents_requested_docs_not_found_path
        end
      end

      context "with an intake that matches the token" do
        it "creates an anonymous intake and sets it in the session" do
          get :edit, params: {token: token}

          new_intake = Intake.last
          expect(new_intake).not_to eq original_intake
          expect(new_intake.intake_ticket_id).to eq 123
          expect(session[:intake_id]).to eq new_intake.id
          expect(session[:anonymous_session]).to eq true
        end
      end
    end

    context "with logged-in session" do
      let(:user) {create :user, intake: original_intake}

      before do
        allow(subject).to receive(:current_user).and_return(user)
      end

      it "no longer checks the token param for a matching intake" do
        get :edit, params: {token: "br0k3nt0k3n"}

        expect(response).not_to redirect_to documents_requested_docs_not_found_path
      end

      it "does not create new intake" do
        expect {
          get :edit, params: {token: token}
        }.not_to change(Intake, :count)
      end

      it "displays the document upload page" do
        get :edit, params: {token: token}

        expect(response).to be_ok
      end

      context "with existing requested document uploads" do
        let!(:old_document) {create :document, :with_upload, document_type: "Requested Later", intake: original_intake}

        it "shows documents on the original intake" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).to include(old_document)
        end
      end
    end

    context "with anonymous session" do
      before do
        session[:anonymous_session] = true
        session[:intake_id] = anonymous_intake.id
      end

      it "no longer checks the token param for a matching intake" do
        get :edit, params: {token: "br0k3nt0k3n"}

        expect(response).not_to redirect_to documents_requested_docs_not_found_path
      end

      it "does not create new intake" do
        expect {
          get :edit, params: {token: token}
        }.not_to change(Intake, :count)
      end

      it "displays the document upload page" do
        get :edit, params: {token: token}

        expect(response).to be_ok
      end

      context "with existing requested document uploads" do
        let!(:old_document) {create :document, :with_upload, document_type: "Requested Later", intake: original_intake}
        let!(:new_document) {create :document, :with_upload, document_type: "Requested Later", intake: anonymous_intake}

        it "does not show documents on the original intake" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).not_to include(old_document)
        end

        it "shows documents on the anonymous intake in the session" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).to include(new_document)
        end
      end
    end
  end

  describe "#update" do
    before do
      allow(subject).to receive(:current_intake).and_return(anonymous_intake)
    end

    context "with valid params" do
      let(:valid_params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("attachments/test-pattern.png")
          }
        }
      end

      it "appends the documents to the intake and rerenders :edit without redirecting" do
        expect {
          post :update, params: valid_params
        }.to change(anonymous_intake.documents, :count).by 1

        latest_doc = anonymous_intake.documents.last
        expect(latest_doc.document_type).to eq "Requested Later"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"

        expect(response).to redirect_to requested_documents_later_documents_path
      end
    end
  end

  describe "#next_path" do
    it "returns send requested documents path" do
      result = subject.next_path

      expect(result).to eq send_requested_documents_later_documents_path
    end
  end
end