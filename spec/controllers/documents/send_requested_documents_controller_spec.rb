require "rails_helper"

RSpec.describe Documents::SendRequestedDocumentsController do
  render_views

  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    it "sends the documents to zendesk, sets a flash notice, and redirects to the home page", active_job: true do
      get :edit

      expect(SendRequestedDocumentsToZendeskJob).to have_been_enqueued
      expect(response).to redirect_to documents_requested_documents_success_path
    end
  end
end

