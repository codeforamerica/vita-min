require "rails_helper"

RSpec.describe Documents::SendRequestedDocumentsLaterController, type: :controller do
  render_views
  let!(:original_intake) { create :intake, intake_ticket_id: 123, created_at: 3.days.ago }
  let!(:anonymous_intake) { create :intake, intake_ticket_id: 123, created_at: 5.minutes.ago }

  describe "#edit" do
    context "when the session is anonymous" do
      let!(:document) { create :document, :with_upload, document_type: "Requested Later", intake: anonymous_intake }

      before do
        session[:intake_id] = anonymous_intake.id
        session[:anonymous_session] = true
      end

      it "adds the document upload job to the queue" do
        get :edit

        expect(SendRequestedDocumentsToZendeskJob).to have_been_enqueued.with(original_intake.id)
        expect(flash[:notice]).to eq "Thank you, your documents have been submitted."
      end

      it "adds the documents to the original intake" do
        get :edit

        expect(original_intake.reload.documents).to include(document)
      end

      it "sets anonymous_session to false" do
        get :edit

        expect(session[:anonymous_session]).to eq false
      end

      it "destroys the anonymous intake" do
        expect {
          get :edit
        }.to change(Intake, :count).by(-1)
      end
    end

    context "when the session is NOT anonymous" do
      let!(:document) { create :document, :with_upload, document_type: "Requested Later", intake: original_intake }

      before do
        session[:intake_id] = original_intake.id
        session[:anonymous_session] = false
      end

      it "adds the document upload job to the queue" do
        get :edit

        expect(SendRequestedDocumentsToZendeskJob).to have_been_enqueued.with(original_intake.id)
        expect(flash[:notice]).to eq "Thank you, your documents have been submitted."
      end

      it "does not duplicate documents" do
        get :edit

        expect(original_intake.reload.documents.count).to eq 1
      end

      it "does NOT destroy the intake on the session" do
        expect {
          get :edit
        }.not_to change(Intake, :count)
      end
    end
  end
end