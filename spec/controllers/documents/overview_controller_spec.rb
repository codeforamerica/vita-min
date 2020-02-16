require "rails_helper"

RSpec.describe Documents::OverviewController do
  render_views
  let(:intake_attributes) { {} }
  let(:intake) { create :intake, **intake_attributes }

  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    before do
      intake.documents = documents
      intake.save
    end

    context "with no document uploads" do
      let(:documents) { [] }

      it "displays an empty message" do
        get :edit
        expect(response.body).to include("No documents of this type were uploaded.")
      end
    end

    context "with documents that have been uploaded" do
      let(:intake_attributes){ { had_wages: "yes" } }
      let(:documents) do
        [
          create(:document, :with_upload, intake: intake, document_type: "W-2"),
          create(:document, :with_upload, intake: intake, document_type: "Other"),
        ]
      end

      it "includes the sections with links to the document types" do
        get :edit

        expect(response.body).to include("W-2")
        expect(response.body).to include(w2s_documents_path)
        expect(response.body).to include(documents[0].upload.filename.to_s)
      end
    end
  end
end
