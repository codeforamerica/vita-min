require "rails_helper"

RSpec.describe UsersController do
  describe "#profile" do
    it_behaves_like :a_get_action_that_redirects_anonymous_users_to_sign_in, action: :profile

    context "with an authenticated user" do
      render_views
      let(:user) { create :agent_user, name: "Adam Avocado" }
      before { sign_in user }

      it "renders information about the current user" do
        get :profile

        expect(response).to be_ok
        expect(response.body).to have_content "Adam Avocado"
      end

      context "who is an admin" do
        let(:user) { create :admin_user }

        it "shows an invitations link" do
          get :profile

          expect(response.body).to include invitations_path
        end
      end

      context "who is just an agent" do
        let(:user) { create :agent_user }

        it "does not show an invitations link" do
          get :profile

          expect(response.body).not_to include invitations_path
        end
      end
    end
  end
end