require "rails_helper"

RSpec.describe Documents::RequestedDocumentsController do
  render_views

  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "with existing document uploads" do
      it "assigns the documents to the form" do
        doc = create :document, :with_upload, document_type: "Requested", intake: intake

        get :edit

        expect(assigns(:documents)).to include(doc)
      end
    end
  end

  describe "#next_path" do
    it "returns send requested documents path" do
      result = subject.next_path

      expect(result).to eq send_requested_documents_documents_path
    end
  end
end

