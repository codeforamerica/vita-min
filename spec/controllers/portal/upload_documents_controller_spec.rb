require "rails_helper"

describe Portal::UploadDocumentsController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :edit

    context "when authenticated" do
      let(:client) { create :client, intake: (build :intake), current_sign_in_at: Time.now }

      before do
        sign_in client
      end

      it "renders the document_upload layout" do
        get :edit
        expect(response).to render_template(:edit, layout: :document_upload)
      end

      context "when a documents request exists for the session" do
        let!(:doc_request) { create(:documents_request, client: client) }
        let(:requested_docs_double) { double RequestedDocumentUploadForm }
        before do
          5.times do
            create(:document, documents_request: doc_request)
          end
          allow(RequestedDocumentUploadForm).to receive(:new).and_return requested_docs_double
        end

        it "does not create a document request" do
          expect {
            get :edit
          }.not_to change(DocumentsRequest, :count)
        end

        it "assigns existing documents on the docs request to @documents" do
          get :edit
          expect(assigns(:documents).length).to eq 5
        end

        it "instantiates a form object" do
          get :edit
          expect(assigns(:form)).to eq requested_docs_double
          expect(RequestedDocumentUploadForm).to have_received(:new).with(doc_request)
        end
      end

      context "when a documents request does not yet exist for the session" do
        it "creates a new documents request" do
          expect {
            get :edit
          }.to change(DocumentsRequest, :count).by(1)
        end

        it "assigns @documents to an empty array because there are no existing documents" do
          get :edit
          expect(assigns(:documents).length).to eq 0
        end

        it "instantiates a form object" do
          get :edit
          expect(assigns(:form)).to be_an_instance_of RequestedDocumentUploadForm
        end
      end
    end
  end

  describe "#update" do
    let(:requested_docs_double) { double RequestedDocumentUploadForm}
    before { allow(RequestedDocumentUploadForm).to receive(:new).and_return requested_docs_double }
    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update
    let(:client) { intake.client }
    let(:intake) { create :intake }

    context "when authenticated" do
      before { sign_in client }

      context "when upload is successful" do
        before do
          allow(requested_docs_double).to receive(:valid?).and_return true
          allow(requested_docs_double).to receive(:save).and_return true
        end

        it "sets a flash message and redirects to new action" do
          put :update
          expect(response).to redirect_to portal_upload_documents_path
          expect(flash[:notice]).to eq I18n.t("portal.upload_documents.success")
        end

        context "when client's tax returns are in not ready or needs doc help" do
          let!(:not_ready_tax_return) { create :tax_return, :intake_in_progress, client: client }
          let!(:needs_doc_help_tax_return) { create :tax_return, :intake_needs_doc_help, year: 2020, client: client }
          let!(:in_review_tax_return) { create :tax_return, :intake_reviewing, year: 2019, client: client }

          it "updates those tax return statuses to ready for review" do
            put :update

            expect(not_ready_tax_return.reload.current_state).to eq "intake_ready"
            expect(needs_doc_help_tax_return.reload.current_state).to eq "intake_ready"
            expect(in_review_tax_return.reload.current_state).to eq "intake_reviewing"
          end
        end
      end

      context "when upload is not successful" do
        before do
          allow(requested_docs_double).to receive(:valid?).and_return false
        end

        it "displays an error message and renders new action" do
          put :update
          expect(response).to render_template :edit
          expect(flash[:error]).to eq I18n.t("portal.upload_documents.error")
        end
      end
    end
  end

  describe "#destroy" do
    let(:client) { create :client }
    let(:params) { { id: client.documents.first.id } }
    before { create :document, client: client }

    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :destroy

    context "when authenticated" do
      before { sign_in client }

      context "when the provided document belongs to the client" do
        it "deletes the document and redirects" do
          expect {
            delete :destroy, params: params
          }.to change(client.documents, :count).by(-1)
          expect(response).to redirect_to portal_upload_documents_path
        end
      end

      context "when the provided document does not belong to the client" do
        let!(:document) { create :document }

        it "does not delete the document" do
          expect {
            delete :destroy, params: { id: document.id }
          }.not_to change(Document, :count)
          expect(response).to redirect_to portal_upload_documents_path
        end
      end
    end
  end
end
