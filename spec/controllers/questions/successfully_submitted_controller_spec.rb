require 'rails_helper'

RSpec.describe Questions::SuccessfullySubmittedController, type: :controller do
  render_views

  describe "#edit" do
    before do
      allow(subject).to receive(:user_signed_in?).and_return(true)
    end

    it "returns http success" do
      get :edit
      expect(response).to have_http_status(:success)
    end
  end
end
