require "rails_helper"

RSpec.describe Hub::AnalyticsController, type: :controller do
  describe "#index" do
    let(:client) { create :client }
    let(:params) { { client_id: client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an admin user loading a client's analytics" do
      before do
        sign_in create(:admin_user)
      end

      it "renders ok" do
        get :index, params: params
        expect(response).to be_ok
      end
    end
  end
end
