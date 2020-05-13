require "rails_helper"

RSpec.describe Documents::OverviewController do
  render_views
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

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
          create(:document, :with_upload, intake: intake, document_type: "W-2"),
          create(:document, :with_upload, intake: intake, document_type: "Other"),
        ]
      end

      it "includes the sections with links to the document types" do
        get :edit

        expect(response.body).to include("W-2")
        expect(response.body).to include(w2s_documents_path)
        expect(response.body).to include(documents[0].upload.filename.to_s)
        expect(response.body).not_to include("Requested")
      end
    end

    context "with a set of answers on an intake" do
      let(:attributes) { { had_wages: "yes", had_retirement_income: "yes" } }

      it "shows section headers for the expected document types" do
        get :edit

        expect(response.body).to include("W-2")
        expect(response.body).to include("1099-R")
        expect(response.body).to include("Other")
        expect(response.body).not_to include("1099-MISC")
        expect(response.body).not_to include("1099-B")
      end
    end
  end
end
