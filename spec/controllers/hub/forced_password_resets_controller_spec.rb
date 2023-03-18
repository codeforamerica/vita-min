require 'rails_helper'

RSpec.describe Hub::ForcedPasswordResetsController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:hub_admin_user) { create(:user, role_type: "AdminRole", timezone: "America/Los_Angeles") }
  let(:non_hub_admin_user) { create(:user, role_type: "GreeterRole") }

  describe "#edit" do
    context "with a logged in user with non-admin hub access" do
      before { sign_in non_hub_admin_user }

      it "shows the form for updating the password" do
        get :edit

        expect(response).to have_rendered(:edit)
      end
    end

    # context "with a logged in non-hub user" do
    #   it "redirects back to the homepage" do
    #     sign_in non_hub_admin_user
    #     get :edit
    #
    #     expect(response).to redirect_to new_user_session_path
    #   end
    # end
  end

  describe "#update" do
    before { sign_in non_hub_admin_user }

    context "with mismatched password" do
      before do
        post :update, params: {user: { password: "one_form_of_pa$$word", password_confirmation: "another_failed_password" } }
        non_hub_admin_user.reload!
      end

      it "fails to update the user's password" do
        expect(response.body).to include "Your new password should be different than your old password."
      end

      it "does not update the last forced reset date" do
        expect(non_hub_admin_user.forced_password_reset_at).to be_nil
      end

      it "does not redirect" do
        expect(response).not_to redirect_to root_path
      end
    end

    context "with matching password" do
      before do
        post :update, params: {
          user: {
            password: "one_form_of_pa$$word", password_confirmation: "one_form_of_pa$$word"
          }
        }
        non_hub_admin_user.reload!
      end

      it "updates the user's password" do
        expect(non_hub_admin_user.encrypted_password_previously_changed?).to be_true
      end

      it "updates the last forced reset date" do
        expect(non_hub_admin_user.forced_password_reset_at).not_to be_nil
      end

      it "redirects to the hub" do
        expect(response).to redirect_to hub_client_path
      end
    end
  end
end
