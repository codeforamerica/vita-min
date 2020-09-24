require "rails_helper"

RSpec.describe UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :profile
    it_behaves_like :a_get_action_for_beta_testers_only, action: :profile

    context "with an authenticated beta tester" do
      render_views
      let(:user) { create :beta_tester, role: "agent", name: "Adam Avocado" }
      before { sign_in user }

      it "renders information about the current user with an invitations link" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
        expect(response.body).to include invitations_path
        expect(response.body).to include clients_path
      end
    end
  end
end