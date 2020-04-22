require 'rails_helper'

RSpec.describe Questions::SuccessfullySubmittedController, type: :controller do
  render_views

  describe "#edit" do
    let(:intake) { create :intake }

    before do
      allow(subject).to receive(:current_intake).and_return(intake)
    end

    it "returns http success" do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end
end
