require "rails_helper"

RSpec.describe Documents::AdditionalDocumentsController do
  render_views

  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "with existing document uploads" do
      it "assigns the documents to the form" do
        doc = create :document, :with_upload, document_type: "Other", intake: intake
        w2_doc = create :document, :with_upload, document_type: "W-2", intake: intake

        get :edit

        expect(assigns(:documents)).to include(doc)
        expect(assigns(:documents)).not_to include(w2_doc)
      end
    end

    context "with a non-image document" do
      let(:document_path) { Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf") }

      it "renders the thumbnails" do
        doc = create :document, :with_upload, document_type: "Other", intake: intake,
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
            document: fixture_file_upload("attachments/test-pattern.png")
          }
        }
      end

      it "appends the documents to the intake and rerenders :edit without redirecting" do
        expect{
          post :update, params: valid_params
        }.to change(intake.documents, :count).by 1

        latest_doc = intake.documents.last
        expect(latest_doc.document_type).to eq "Other"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"

        expect(response).to redirect_to additional_documents_documents_path
      end
    end
  end
end

