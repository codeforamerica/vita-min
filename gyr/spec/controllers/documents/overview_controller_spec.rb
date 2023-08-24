require "rails_helper"

RSpec.describe Documents::OverviewController do
  render_views
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }
  before { sign_in intake.client }

  describe "#edit" do
    let(:documents) { [] }

    before do
      intake.documents = documents
      intake.save
    end

    context "with no document uploads" do
      it "displays an empty message" do
        get :edit
        expect(response.body).to include("No documents of this type were uploaded.")
      end

      it "does not display requested documents in the list" do
        get :edit
        expect(response.body).not_to include("Requested")
      end
    end

    context "with documents that have been uploaded" do
      let(:attributes) { { had_wages: "yes" } }
      let(:documents) do
        [
          create(:document, intake: intake, document_type: "Employment"),
          create(:document, intake: intake, document_type: "Other"),
        ]
      end

      it "includes the sections with links to the document types" do
        get :edit

        expect(response.body).to include("Employment")
        expect(response.body).to include(employment_documents_path)
        expect(response.body).to include(documents[0].upload.filename.to_s)
        expect(response.body).not_to include("Requested")
      end
    end

    context "with a set of answers on an intake" do
      let(:attributes) { { had_wages: "yes", had_retirement_income: "yes" } }

      it "shows section headers for the expected document types" do
        get :edit

        expect(response.body).to include("Employment")
        expect(response.body).to include("Retirement Income")
        expect(response.body).to include("Other")
        expect(response.body).not_to include("1099-B")
      end
    end
  end


  describe "#delete" do
    let!(:document) { create :document, intake: intake }

    let(:params) do
      { id: document.id }
    end

    it "allows client to delete their own document and records a paper trail" do
      delete :destroy, params: params

      expect(PaperTrail::Version.last.event).to eq "destroy"
      expect(PaperTrail::Version.last.whodunnit).to eq intake.client.id.to_s
      expect(PaperTrail::Version.last.item_id).to eq document.id
    end
  end
end
