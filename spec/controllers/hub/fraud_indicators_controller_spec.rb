require "rails_helper"

describe Hub::FraudIndicatorsController do
  describe "index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    before do
      create(:fraud_indicator, activated_at: nil)
      create(:fraud_indicator, activated_at: nil)
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
        expect(assigns(:fraud_indicators).length).to eq Fraud::Indicator.unscoped.count
      end
    end
  end
end