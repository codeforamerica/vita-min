require 'rails_helper'

describe Hub::ForcedPasswordResetsController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#edit" do
    context "with a logged in user with hub access" do
      before { sign_in user }

      it "shows the form for updating the password" do
        get :edit

        expect(response).to have_rendered(:edit)
      end
    end

    context "with a logged in non-hub user" do
      it "redirects back to the homepage" do
        get :edit

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "#update" do
    before { sign_in user }

    context "with mismatched password" do
      before do
        post :update, params: {user: { password: "one_form_of_pa$$word", password_confirmation: "another_failed_password" } }
      end

      it "fails to update the user's password" do
        expect(response.body).to include "Your new password should be different than your old password."
      end

      it "does not update the last forced reset date" do
        user.reload!
        expect(user.forced_password_reset_at).to be_nil
      end

      it "does not redirect" do
        expect(response).not_to redirect_to root_path
      end
    end

    context "with matching password" do
      before do
        post :update, params: {user: { password: "one_form_of_pa$$word", password_confirmation: "one_form_of_pa$$word" } }
      end

      it "updates the user's password" do
        expect(user.encrypted_password_previously_changed?).to be_true
      end

      it "updates the last forced reset date" do
        expect(user.forced_password_reset_at).not_to be_nil
      end

      it "redirects to the hub" do
        expect(response).to redirect_to hub_client_path
      end
    end
  end
end
