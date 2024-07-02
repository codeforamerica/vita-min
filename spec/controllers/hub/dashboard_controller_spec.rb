require "rails_helper"

RSpec.describe Hub::DashboardController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#index" do
    #it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with an authorized user" do
      before { sign_in user }
      render_views

      it "responds with ok" do
        get :index
        expect(response).to redirect_to "/en/hub/dashboard/#{VitaPartner.last.id}"
      end
    end
  end

  describe "#show" do
    #it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "with an authorized user" do
      before { sign_in user }
      render_views

      it "responds with ok" do
        get :show, params: { id: VitaPartner.last.id }
        expect(response).to be_ok
      end
    end
  end
end
