require "rails_helper"

RSpec.describe Documents::SendRequestedDocumentsLaterController, type: :controller do
  let!(:original_intake) { create :intake, created_at: 3.days.ago }
  let!(:documents_request) { create :documents_request, intake: original_intake }

  describe "#edit" do
    context "with a documents request in the session" do
      let!(:document) { create :document, document_type: "Requested Later", intake: original_intake, documents_request: documents_request }

      before do
        session[:documents_request_id] = documents_request.id
      end

      it "clears the session and redirects to root path" do
        get :edit
        expect(documents_request.reload.completed_at).not_to be_nil
        expect(session[:documents_request_id]).to be_nil

        expect(response).to redirect_to(root_path)
      end
    end

    context "without an existing documents request in the session" do
      it "successfully redirects to root path" do
        get :edit
        expect(session[:documents_request_id]).to be_nil

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
