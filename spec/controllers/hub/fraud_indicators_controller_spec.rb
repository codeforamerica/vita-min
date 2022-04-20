require "rails_helper"

describe Hub::FraudIndicatorsController do
  describe "index" do
    before do
      create(:duplicate_fraud_indicator, activated_at: nil)
      create(:duplicate_fraud_indicator, activated_at: nil)
    end

    context "when the client is authenticated" do
      let(:user) { create :admin_user }
      before do
        sign_in user
      end

      it "renders" do
        get :index
        expect(response.status).to eq 200
      end

      it "loads all fraud indicators, active and not" do
        get :index
        expect(assigns(:fraud_indicators).length).to eq 2
      end
    end
  end
end