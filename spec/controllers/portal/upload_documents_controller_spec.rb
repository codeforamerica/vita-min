require "rails_helper"

describe Portal::UploadDocumentsController do
  describe "#new" do
    context "when not authenticated" do
      it "redirects to root" do
        get :new
        expect(response).to redirect_to :root
      end
    end

    context "when authenticated" do
      let(:client) { create :client, intake: (create :intake), current_sign_in_at: Time.now }

      before do
        sign_in client
      end

      it 'renders the document_upload layout' do
        get :new
        expect(response).to render_template(:new, layout: :document_upload)
      end

      context "when a documents request exists for the session" do
        let!(:doc_request) { create(:documents_request, intake: client.intake) }
        let(:requested_docs_double) { double RequestedDocumentUploadForm }
        before do
          5.times do
            create(:document, documents_request: doc_request)
          end
          allow(RequestedDocumentUploadForm).to receive(:new).and_return requested_docs_double
        end

        it "does not create a document request" do
          expect {
            get :new
          }.not_to change(DocumentsRequest, :count)
        end

        it "assigns existing documents on the docs request to @documents" do
          get :new
          expect(assigns(:documents).length).to eq 5
        end

        it "instantiates a form object" do
          get :new
          expect(assigns(:form)).to eq requested_docs_double
          expect(RequestedDocumentUploadForm).to have_received(:new).with(doc_request)
        end
      end

      context "when a documents request does not yet exist for the session" do
        it "does not create a document request" do
          expect {
            get :new
          }.to change(DocumentsRequest, :count).by(1)
        end

        it "assigns @documents to an empty array because there are no existing documents" do
          get :new
          expect(assigns(:documents).length).to eq 0
        end

        it "instantiates a form object" do
          get :new
          expect(assigns(:form)).to be_an_instance_of RequestedDocumentUploadForm
        end
      end
    end
  end

  describe '#create' do
    context "when not authenticated" do
      it "redirects to root" do
        get :new
        expect(response).to redirect_to :root
      end
    end

    context "when authenticated" do
      let(:requested_docs_double) { double RequestedDocumentUploadForm}
      before do
        sign_in create :client
        allow(RequestedDocumentUploadForm).to receive(:new).and_return requested_docs_double

      end

      context "when upload is successful" do
        before do
          allow(requested_docs_double).to receive(:valid?).and_return true
          allow(requested_docs_double).to receive(:save).and_return true
        end

        it "sets a flash message and redirects to new action" do
          post :create
          expect(response).to redirect_to new_portal_upload_document_path
          expect(flash[:notice]).to eq I18n.t("portal.upload_documents.success")
        end
      end

      context "when upload is not successful" do
        before do
          allow(requested_docs_double).to receive(:valid?).and_return false
        end

        it "displays an error message and renders new action" do
          post :create
          expect(response).to render_template :new
          expect(flash[:error]).to eq I18n.t("portal.upload_documents.error")
        end
      end
    end
  end

  describe "#destroy" do
    context "when not authenticated" do
      it "redirects to root" do
        get :new
        expect(response).to redirect_to :root
      end
    end

    context "when authenticated" do
      let(:client) { create :client }
      before do
        sign_in client
        create :document, client: client
      end

      context "when the provided document belongs to the client" do
        it "deletes the document and redirects" do
          expect {
            delete :destroy, params: { id: client.documents.first.id }
          }.to change(client.documents, :count).by(-1)
          expect(response).to redirect_to new_portal_upload_document_path
        end
      end

      context "when the provided document does not belong to the client" do
        it "does not delete the document" do
          expect {
            delete :destroy, params: { id: 900000 }
          }.not_to change(Document, :count)
          expect(response).to redirect_to new_portal_upload_document_path
        end
      end
    end
  end
end