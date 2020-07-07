require "rails_helper"

RSpec.describe Documents::SendRequestedDocumentsLaterController, type: :controller do
  render_views
  let!(:original_intake) { create :intake, intake_ticket_id: 123, created_at: 3.days.ago }
  let!(:documents_request) { create :documents_request, intake: original_intake }

  describe "#edit" do
    context "with a documents request in the session" do
      let!(:document) { create :document, :with_upload, document_type: "Requested Later", documents_request: documents_request }

      before do
        session[:documents_request_id] = documents_request.id
      end

      it "adds the document upload job to the queue" do
        get :edit

        expect(SendRequestedDocumentsToZendeskJob).to have_been_enqueued.with(original_intake.id)
        expect(response).to redirect_to(root_path)
      end

      it "adds the documents to the original intake" do
        get :edit

        expect(original_intake.reload.documents).to include(document)
      end

      it "clears the session" do
        get :edit

        expect(session[:documents_request_id]).to be_nil
      end
    end
  end
end