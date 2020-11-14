require "rails_helper"

RSpec.describe Documents::SendRequestedDocumentsLaterController, type: :controller do
  render_views
  let!(:original_intake) { create :intake, intake_ticket_id: 123, created_at: 3.days.ago }
  let!(:documents_request) { create :documents_request, intake: original_intake }
  before do
    # everything should still work in the offseason
    allow(Rails.configuration).to receive(:offseason).and_return true
    Rails.application.reload_routes!
  end

  after do
    allow(Rails.configuration).to receive(:offseason).and_call_original
    Rails.application.reload_routes!
  end

  describe "#edit" do
    context "with a documents request in the session" do
      let!(:document) { create :document, :with_upload, document_type: "Requested Later", intake: original_intake, documents_request: documents_request }

      before do
        session[:documents_request_id] = documents_request.id
      end

      it "clears the session and redirects to root path" do
        get :edit

        expect(session[:documents_request_id]).to be_nil
        expect(response).to redirect_to(root_path)
      end
    end
  end
end