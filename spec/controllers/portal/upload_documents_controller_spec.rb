require "rails_helper"

describe Portal::UploadDocumentsController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit

    context "when authenticated" do
      let(:client) { create :client, intake: (build :intake), current_sign_in_at: Time.now }
      let!(:active_document) { create :document, client: client }
      let!(:archived_document) { create :document, client: client, archived: true }

      before do
        sign_in client
      end

      it "renders a list of active documents" do
        get :index
        expect(assigns[:documents]).to match_array([active_document])
      end
    end
  end

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
        let(:requested_docs_double) { double Portal::DocumentUploadForm }
        before do
          5.times do
            create(:document, intake: client.intake, document_type: 'ID')
          end
          create(:document, intake: client.intake, document_type: 'ID', archived: true)
          allow(Portal::DocumentUploadForm).to receive(:new).and_return requested_docs_double
        end

        it "assigns existing active documents for the intake of the matching type to @documents" do
          get :edit, params: { type: 'ID' }
          expect(assigns(:documents).length).to eq 5
        end

        it "instantiates a form object" do
          get :edit
          expect(assigns(:form)).to eq requested_docs_double
          expect(Portal::DocumentUploadForm).to have_received(:new).with(client.intake)
        end
      end
    end
  end

  describe "#update" do
    let(:requested_docs_double) { double Portal::DocumentUploadForm}
    before { allow(Portal::DocumentUploadForm).to receive(:new).and_return requested_docs_double }
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
          let!(:not_ready_tax_return) { create :gyr_tax_return, :intake_in_progress, client: client }
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

      context "when the document is archived" do
        let!(:document) { create :document, archived: true, client: client }

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
