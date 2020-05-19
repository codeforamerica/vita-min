require 'rails_helper'

RSpec.describe Questions::SuccessfullySubmittedController, type: :controller do
  render_views

  describe "#include_google_analytics?" do
    it "returns true" do
      expect(subject.include_google_analytics?).to eq true
    end
  end

  describe "#edit" do
    let(:intake) { create :intake, intake_ticket_id: 1234 }

    before do
      allow(subject).to receive(:current_intake).and_return(intake)
    end

    it "returns http success" do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end
end
