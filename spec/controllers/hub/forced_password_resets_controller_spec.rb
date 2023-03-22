require 'rails_helper'

RSpec.describe Hub::ForcedPasswordResetsController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:hub_admin_user) { create(:user, role_type: "AdminRole", timezone: "America/Los_Angeles") }
  let(:non_hub_admin_user) { create(:user, role_type: "GreeterRole", forced_password_reset_at: nil) }

  render_views

  describe "#edit" do
    context "with a logged in user with non-admin hub access" do
      before { sign_in non_hub_admin_user }

      it "shows the form for updating the password" do
        get :edit
        expect(response).to have_rendered(:edit)
      end

      it "redirects if the password was already reset" do
        non_hub_admin_user.update!(forced_password_reset_at: DateTime.now)

        get :edit
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end

    context "with a logged in user with admin hub access" do
      before { sign_in hub_admin_user }

      it "redirects to the expected page post-sign-in" do
        get :edit
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end

  end

  describe "#update" do
    before { sign_in non_hub_admin_user }

    context "with the same password" do
      before do
        put :update, params: {
          user: {
            password: non_hub_admin_user.password,
            password_confirmation: "another_failed_password"
          }
        }
        non_hub_admin_user.reload
      end

      it "fails to update the user's password" do
        expect(response.body).to include I18n.t("errors.attributes.password.must_be_different")
      end

      it "does not update the last forced reset date" do
        expect(non_hub_admin_user.forced_password_reset_at).to be_nil
      end

      it "does not redirect" do
        expect(response).not_to redirect_to root_path
      end
    end

    context "with new password with a mismatched confirmation" do
      before do
        put :update, params: {
          user: {
            password: non_hub_admin_user.password + "new",
            password_confirmation: "another_failed_password"
          }
        }

        non_hub_admin_user.reload
      end

      it "fails to update the user's password" do
        expect(non_hub_admin_user.valid_password?("one_form_of_pa$$word")).to be false
        expect(response.body).to include I18n.t("errors.attributes.password.not_matching")
      end

      it "does not update the last forced reset date" do
        expect(non_hub_admin_user.forced_password_reset_at).to be_nil
      end

      it "does not redirect" do
        expect(response).not_to redirect_to root_path
      end
    end

    context "with new password with a matching confirmation" do
      before do
        put :update, params: {
          user: {
            password: "one_form_of_pa$$word", password_confirmation: "one_form_of_pa$$word"
          }
        }
        non_hub_admin_user.reload
      end

      it "updates the user's password" do
        expect(non_hub_admin_user.valid_password?("one_form_of_pa$$word")).to be true
      end

      it "updates the last forced reset date" do
        expect(non_hub_admin_user.forced_password_reset_at).not_to be_nil
      end

      it "redirects to the hub" do
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end
  end
end
