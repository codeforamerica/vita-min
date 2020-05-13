require "rails_helper"

RSpec.describe Documents::RequestedDocumentsLaterController, type: :controller do
  render_views
  let(:token) {"t0k3nN0tbr0k3n?"}
  let!(:original_intake) { create :intake, requested_docs_token: token, intake_ticket_id: 123 }
  let!(:documents_request) { create :documents_request, intake: original_intake }


  describe "#edit" do
    context "with no session" do
      context "with no intake matching the token" do
        it "redirects to an error page" do
          get :edit, params: {token: "br0k3nt0k3n"}

          expect(response).to redirect_to documents_requested_docs_not_found_path
        end
      end

      context "with an intake that matches the token" do
        it "creates a DocumentsRequest for the intake and sets it in the session" do
          get :edit, params: {token: token}

          documents_request = DocumentsRequest.last
          expect(documents_request.intake).to eq original_intake
          expect(session[:documents_request_id]).to eq documents_request.id
        end
      end
    end

    context "with documents request session" do
      before do
        session[:documents_request_id] = documents_request.id
      end

      context "requires document to continue" do
        context "requiring an upload" do
          render_views

          context "when they first arrive on the page" do
            it "includes a disabled button but no link to next path" do
              get :edit

              expect(response.body).to have_css("button[disabled].button--disabled")
              expect(response.body).not_to have_css("a.button--cta")
            end
          end

          context "when they have uploaded one document" do
            before do
              create :document, :with_upload, documents_request: documents_request, document_type: controller.document_type
            end

            it "renders a link to the next path" do
              get :edit

              expect(response.body).to have_css("a.button--cta")
              expect(response.body).not_to have_css("button[disabled].button--disabled")
            end
          end
        end
      end

      it "no longer checks the token param for a matching intake" do
        get :edit, params: {token: "br0k3nt0k3n"}

        expect(response).not_to redirect_to documents_requested_docs_not_found_path
      end

      it "does not create new documents request" do
        expect {
          get :edit, params: {token: token}
        }.not_to change(DocumentsRequest, :count)
      end

      it "displays the document upload page" do
        get :edit, params: {token: token}

        expect(response).to be_ok
      end

      context "with existing requested document uploads" do
        let!(:old_document) {create :document, :with_upload, document_type: "Requested Later", intake: original_intake}
        let!(:new_document) {create :document, :with_upload, document_type: "Requested Later", documents_request: documents_request}

        it "does not show documents on the original intake" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).not_to include(old_document)
        end

        it "shows documents on the documents request in the session" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).to include(new_document)
        end
      end
    end
  end

  describe "#update" do
    context "with no documents request in the session" do
      it "redirects to the home page" do
        get :update

        expect(response).to redirect_to root_path
      end
    end

    context "with a documents request in the session" do
      before do
        session[:documents_request_id] = documents_request.id
      end

      context "with valid params" do
        let(:valid_params) do
          {
            requested_document_upload_form: {
              document: fixture_file_upload("attachments/test-pattern.png")
            }
          }
        end

        it "appends the documents to the documents request and redirects to :edit" do
          expect {
            post :update, params: valid_params
          }.to change(documents_request.documents, :count).by 1

          latest_doc = documents_request.documents.last
          expect(latest_doc.document_type).to eq "Requested Later"
          expect(latest_doc.upload.filename).to eq "test-pattern.png"

          expect(response).to redirect_to requested_documents_later_documents_path
        end
      end
    end
  end

  describe "#next_path" do
    it "returns send requested documents path" do
      result = subject.next_path

      expect(result).to eq send_requested_documents_later_documents_path
    end
  end

  describe "#delete" do
    context "when the document id belongs to the current documents request" do
      let!(:document) { create :document, documents_request: documents_request }

      before do
        session[:documents_request_id] = documents_request.id
      end

      it "allows them to delete their own document and redirects back" do
        expect do
          delete :destroy, params: { id: document.id }
        end.to change(Document, :count).by(-1)

        expect(response).to redirect_to requested_documents_later_documents_path
      end
    end

    context "when the documents id does not match the current documents request" do
      let!(:document) { create :document }

      before do
        session[:documents_request_id] = documents_request.id
      end

      it "does not allow them to delete the document and redirects to home" do
        expect do
          delete :destroy, params: { id: document.id }
        end.not_to change(Document, :count)

        expect(response).to redirect_to root_path
      end
    end

    context "when there is no documents request in the session" do
      let!(:document) { create :document }

      it "does not allow them to delete the document and redirects to home" do
        expect do
          delete :destroy, params: { id: document.id }
        end.not_to change(Document, :count)

        expect(response).to redirect_to root_path
      end
    end
  end
end
