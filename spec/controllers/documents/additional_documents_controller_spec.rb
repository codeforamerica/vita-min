require "rails_helper"

RSpec.describe Documents::AdditionalDocumentsController do
  render_views

  let(:intake) { create :intake }
  before { sign_in intake.client }

  describe "#edit" do
    let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client }

    it "advances the tax returns to 'Ready for review' status" do
      get :edit

      expect(tax_return.reload.status).to eq "intake_ready"
    end

    context "with no docs that might be needed" do
      it "does not show an extra list of docs" do
        get :edit

        expect(response.body).not_to include I18n.t("views.documents.additional_documents.document_list_title")
      end
    end

    context "with an intake that has some docs that might be needed" do
      let(:intake) do
        create(
          :intake,
          had_local_tax_refund: "yes",
          had_unemployment_income: "yes",
          had_gambling_income: "yes"
        )
      end

      it "lists the relevant documents" do
        get :edit

        expect(response.body).to include "W-2G"
        expect(response.body).to include "1099-G"
        expect(response.body).to include "Prior Year Tax Return"
      end
    end

    context "with existing document uploads" do
      it "assigns the documents to the form" do
        doc = create :document, document_type: "Other", intake: intake
        w2_doc = create :document, document_type: "Employment", intake: intake

        get :edit

        expect(assigns(:documents)).to include(doc)
        expect(assigns(:documents)).not_to include(w2_doc)
      end
    end

    context "with a non-image document" do
      let(:document_path) { Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf") }

      it "renders the thumbnails" do
        create :document, document_type: "Other", intake: intake,
          upload_path: document_path

        expect { get :edit }.not_to raise_error
        expect(response.body).to include('document_bundle.pdf')
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:valid_params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("test-pattern.png")
          }
        }
      end

      it "appends the documents to the intake and rerenders :edit without redirecting" do
        expect{
          post :update, params: valid_params
        }.to change(intake.documents, :count).by 1

        latest_doc = intake.documents.last
        expect(intake.client.documents.last).to eq latest_doc
        expect(latest_doc.document_type).to eq "Other"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"
        expect(latest_doc.uploaded_by).to eq intake.client
        expect(response).to redirect_to additional_documents_documents_path
      end
    end

    context "with invalid params & maybe needed docs" do
      let(:invalid_params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("test-pattern.html")
          }
        }
      end
      let(:intake) do
        create(
          :intake,
          had_local_tax_refund: "yes",
          had_unemployment_income: "yes",
          had_gambling_income: "yes"
        )
      end

      it "renders edit and lists documents that might be needed" do
        post :update, params: invalid_params

        expect(response).to render_template(:edit)
        expect(response.body).to include "W-2G"
        expect(response.body).to include "1099-G"
        expect(response.body).to include "Prior Year Tax Return"
      end
    end
  end
end

