require "rails_helper"

RSpec.describe Documents::RequestedDocumentsLaterController, type: :controller do
  render_views
  let(:token) {"t0k3nN0tbr0k3n?"}
  let!(:original_intake) { create :intake, requested_docs_token: token, intake_ticket_id: 123 }
  let!(:documents_request) { create :documents_request, intake: original_intake }

  describe "#edit" do
    context "with no session" do

      context "with no token in the params" do
        it "redirects to an error page" do
          get :edit, params: {}

          expect(response).to redirect_to documents_requested_docs_not_found_path
        end
      end
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
              expect(response.body).not_to have_css("a.button--primary")
            end
          end

          context "when they have uploaded one document" do
            before do
              create :document, :with_upload, documents_request: documents_request, document_type: controller.document_type_key
            end

            it "renders a link to the next path" do
              get :edit

              expect(response.body).to have_css("a.button--primary")
              expect(response.body).not_to have_css("button[disabled].button--disabled")
            end
          end
        end
      end

      context "when returning after upload (no token param)" do
        it "no longer checks the token param for a matching intake" do
          get :edit

          expect(response).not_to redirect_to documents_requested_docs_not_found_path
        end

        it "does not create new documents request" do
          expect { get :edit }.not_to change(DocumentsRequest, :count)
        end

        it "displays the document upload page" do
          get :edit

          expect(response).to be_ok
        end
      end

      context "when returning with a different token param" do
        let(:new_token) { create(:intake).get_or_create_requested_docs_token }

        it "create a new documents request" do
          expect { get :edit, params: { token: new_token } }
            .to change(DocumentsRequest, :count)
        end

        it "replaces the documents_request_id in the session" do
          expect { get :edit, params: { token: new_token } }
            .to change { session[:documents_request_id] }
        end
      end

      context "with existing requested document uploads" do
        let!(:old_document) {create :document, :with_upload, document_type: "Requested Later", intake: original_intake}
        let!(:new_document) {create :document, :with_upload, document_type: "Requested Later", documents_request: documents_request}

        it "does not show documents on the original intake" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).not_to include(old_document)
        end

        it "shows documents on the documents request for matching token" do
          get :edit, params: {token: token}

          expect(assigns(:documents)).to include(new_document)
        end

        it "shows documents on the documents request matching session" do
          session[:documents_request_id] = documents_request.id
          get :edit

          expect(assigns(:documents)).not_to include(old_document)
          expect(assigns(:documents)).to include(new_document)
        end
      end
    end
  end

  describe "#update" do
    let(:valid_params) do
      {
        requested_document_upload_form: {
          document: fixture_file_upload("attachments/test-pattern.png")
        }
      }
    end
    context "with no documents request in the session" do
      it "redirects to the home page" do
        post :update, params: valid_params

        expect(response).to redirect_to root_path
      end

      context "with an authenticity token error and a non-default locale" do
        around do |example|
          ActionController::Base.allow_forgery_protection = true
          example.run
          #ActionController::Base.allow_forgery_protection = false
        end

        let(:params) do
          {
            requested_document_upload_form: {
              document: fixture_file_upload("attachments/test-pattern.png")
            },
            locale: :es
          }
        end

        it "redirects to home page with a flash message and maintains locale" do
          post :update, params: params

          expect(response).to redirect_to(root_path(locale: :es))
          expect(flash[:warning]).to match("Lo sentimos, no pudimos cargar su documento")
        end
      end
    end

    context "with a documents request in the session" do
      before do
        session[:documents_request_id] = documents_request.id
      end

      context "with valid params" do
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

      context "with invalid params" do
        let(:invalid_params) do
          {
            requested_document_upload_form: {
              document: fixture_file_upload("attachments/test-pattern.html")
            }
          }
        end

        it "does not upload the attachment, redirects to :edit and shows a validation error" do
          expect {
            post :update, params: invalid_params
          }.not_to change(documents_request.documents, :count)

          expect(response.body).to include I18n.t("validators.file_type")
          expect(response).to render_template(:edit)
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
