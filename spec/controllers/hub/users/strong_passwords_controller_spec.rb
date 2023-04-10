require 'rails_helper'

RSpec.describe Hub::Users::StrongPasswordsController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:hub_admin_user) { create(:user, role_type: "AdminRole", timezone: "America/Los_Angeles") }
  let(:non_hub_admin_user) { create(:user, role_type: "GreeterRole", high_quality_password_as_of: nil) }

  render_views

  describe "#edit" do
    context "with a logged in user with non-admin hub access" do
      before { sign_in non_hub_admin_user }

      it "shows the form for updating the password" do
        get :edit
        expect(response).to be_ok
      end

      context "when password is already reset" do
        before do
          non_hub_admin_user.update!(high_quality_password_as_of: DateTime.now)
        end

        it "redirects to default login path" do
          get :edit
          expect(response).to redirect_to hub_assigned_clients_path
        end
      end
    end

    context "with a logged in user with admin hub access" do
      before { sign_in hub_admin_user }

      it "redirects to the expected page post-sign-in" do
        get :edit
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end

    context "when no one is signed in" do
      it "redirects to the sign in page" do
        get :edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#update" do
    before { sign_in non_hub_admin_user }

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
        expect(non_hub_admin_user.high_quality_password_as_of).to be_nil
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
        expect(non_hub_admin_user.high_quality_password_as_of).not_to be_nil
      end

      it "redirects to the hub" do
        expect(response).to redirect_to hub_assigned_clients_path
      end
    end
  end
end
