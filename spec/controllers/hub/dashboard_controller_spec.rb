require "rails_helper"

RSpec.describe Hub::DashboardController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    render_views

    context "as an authenticated user" do
      before { sign_in user }

      it "responds with ok" do
        get :index
        expect(response).to be_ok
      end

      # TODO: we need to test what it displays here depending on the role...
    end
  end
end
